class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[ show edit update destroy details ]
  before_action -> { require_permission!(:appointments, :view) }, only: %i[index show details]
  before_action -> { require_permission!(:appointments, :create) }, only: %i[new create available_slots]
  before_action -> { require_permission!(:appointments, :update) }, only: %i[edit update]
  before_action -> { require_permission!(:appointments, :destroy) }, only: :destroy

  # GET /appointments or /appointments.json
  def index
    @selected_date = parse_selected_date(params[:date])
    load_weekly_dashboard(@selected_date || Time.zone.today)
    @selected_day_appointments = if @selected_date.present?
      Appointment.includes(:patient, :user).where(starts_at: @selected_date.all_day).order(:starts_at)
    else
      []
    end
  end

  # GET /appointments/1 or /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new(
      patient_id: params[:patient_id],
      status: "pending",
      source: "admin",
      booking_type: "scheduled",
      buffer_minutes: 10
    )
    set_available_slots
  end

  def available_slots
    @appointment = Appointment.new(
      clinic_service_id: params[:clinic_service_id],
      user_id: params[:user_id],
      time_preference: params[:time_preference],
      starts_at: params[:starts_at],
      ends_at: params[:ends_at]
    )
    set_available_slots

    render partial: "available_slots_calendar"
  end

  # GET /appointments/1/edit
  def edit
    set_available_slots
  end

  # GET /appointments/1/details
  def details
    @week_date = parse_selected_date(params[:week_date]) || @appointment.starts_at&.to_date || Time.zone.today
    render partial: "details_modal", locals: { appointment: @appointment, week_date: @week_date }
  end

  # POST /appointments or /appointments.json
  def create
    @appointment = Appointment.new(appointment_params)

    respond_to do |format|
      if @appointment.save
        format.html { redirect_to @appointment, notice: "Appointment was successfully created." }
        format.turbo_stream { redirect_to @appointment, notice: "Appointment was successfully created." }
        format.json { render :show, status: :created, location: @appointment }
      else
        set_available_slots
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, formats: :html, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1 or /appointments/1.json
  def update
    respond_to do |format|
      if @appointment.update(appointment_params)
        @week_date = parse_selected_date(params[:week_date]) || @appointment.starts_at&.to_date || Time.zone.today
        load_weekly_dashboard(@week_date)
        format.html { redirect_to @appointment, notice: "Appointment was successfully updated.", status: :see_other }
        format.turbo_stream
        format.json { render :show, status: :ok, location: @appointment }
      else
        set_available_slots
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, formats: :html, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1 or /appointments/1.json
  def destroy
    @appointment.destroy!

    respond_to do |format|
      format.html { redirect_to appointments_path, notice: "Appointment was successfully destroyed.", status: :see_other }
      format.turbo_stream { redirect_to appointments_path, notice: "Appointment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def appointment_params
      params.expect(appointment: [
        :patient_id,
        :user_id,
        :clinic_service_id,
        :time_preference,
        :source,
        :booking_type,
        :starts_at,
        :ends_at,
        :status,
        :operatory,
        :cancellation_reason,
        :rescheduled_from_appointment_id,
        :notes
      ])
    end

    def parse_selected_date(raw_date)
      return if raw_date.blank?

      Date.iso8601(raw_date)
    rescue ArgumentError
      nil
    end

    def load_weekly_dashboard(base_day)
      @appointments = Appointment.includes(:patient, :user).order(:starts_at)
      @week_start = base_day.beginning_of_week(:monday)
      @week_end = @week_start + 4.days
      @previous_week_start = @week_start - 1.week
      @next_week_start = @week_start + 1.week
      @weekly_appointments = Appointment.includes(:patient, :user)
                                        .where(starts_at: @week_start.beginning_of_day..@week_end.end_of_day)
                                        .order(:starts_at)
      @available_slots = AppointmentScheduler.new(date: base_day).slots(limit: 8)
    end

    def set_available_slots
      @selected_service = ClinicService.find_by(id: @appointment.clinic_service_id)
      slot_buffer_minutes = @appointment.buffer_minutes.presence || 10
      @slot_view = params[:slot_view].presence_in(%w[week month]) || "week"
      @slot_date = parse_selected_date(params[:slot_date]) || @appointment.starts_at&.to_date || Time.zone.today
      @slot_range = if @slot_view == "month"
        @slot_date.beginning_of_month..@slot_date.end_of_month
      else
        @slot_date.beginning_of_week(:monday)..(@slot_date.beginning_of_week(:monday) + 6.days)
      end

      @available_slots_by_date = @slot_range.index_with do |date|
        raw_slots = AppointmentScheduler.new(
          date: date,
          clinic_service: @selected_service,
          duration_minutes: @appointment.duration_minutes.presence || @selected_service&.duration_minutes,
          preparation_minutes: @selected_service&.preparation_minutes,
          buffer_minutes: slot_buffer_minutes,
          preferred_user: @appointment.user
        ).slot_cards.then { |slots| filter_slot_cards(slots) }

        available_slots = raw_slots.select { |slot| slot[:status] == "available" }
        recommended_slots = rank_available_slots(available_slots.first(3))
        remaining_slots = rank_available_slots(available_slots.drop(3))

        (recommended_slots + remaining_slots).tap do |slots|
          slots.each_with_index do |slot, index|
            slot[:recommended] = index < 3
          end
        end
      end
      @slot_duration_minutes = @selected_service&.duration_minutes || @appointment.duration_minutes.presence || 30
      @slot_preparation_minutes = @selected_service&.preparation_minutes || 0
      @slot_buffer_minutes = slot_buffer_minutes
      @slot_total_minutes = @slot_duration_minutes + @slot_preparation_minutes + @slot_buffer_minutes
      @available_slots_count = @available_slots_by_date.values.flatten.count { |slot| slot[:status] == "available" }
      @earliest_available_slot = @available_slots_by_date.values.flatten.find { |slot| slot[:status] == "available" }
    end

    def filter_slot_cards(slots)
      case @appointment.time_preference
      when "morning"
        slots.select { |slot| slot[:period] == "morning" }
      when "afternoon"
        slots.select { |slot| slot[:period] == "afternoon" }
      when "specific_time"
        return slots if @appointment.starts_at.blank?

        slots.select { |slot| slot[:starts_at].to_i == @appointment.starts_at.to_i }
      else
        slots
      end
    end

    def rank_available_slots(slots)
      slots.sort_by do |slot|
        [
          recommendation_weight(slot),
          slot[:starts_at]
        ]
      end
    end

    def recommendation_weight(slot)
      return 0 if @appointment.time_preference == "specific_time" && @appointment.starts_at.present? && slot[:starts_at].to_i == @appointment.starts_at.to_i
      return 0 if @appointment.time_preference == "morning" && slot[:period] == "morning"
      return 0 if @appointment.time_preference == "afternoon" && slot[:period] == "afternoon"
      return 1 if slot[:starts_at] >= Time.current

      2
    end

    def clinic_close_at(date)
      schedule = ClinicSchedule.for_date(date)

      closes_at = schedule&.closes_at || Time.zone.parse("17:00")
      Time.zone.local(date.year, date.month, date.day, closes_at.hour, closes_at.min, closes_at.sec)
    end
end
