class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[ show edit update destroy ]

  # GET /appointments or /appointments.json
  def index
    @selected_date = parse_selected_date(params[:date])
    base_day = @selected_date || Time.zone.today
    @appointments = Appointment.includes(:patient, :user).order(:starts_at)
    @week_start = base_day.beginning_of_week(:monday)
    @week_end = @week_start + 4.days
    @weekly_appointments = Appointment.includes(:patient, :user)
                                      .where(starts_at: @week_start.beginning_of_day..@week_end.end_of_day)
                                      .order(:starts_at)
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
    @appointment = Appointment.new
  end

  # GET /appointments/1/edit
  def edit
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
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1 or /appointments/1.json
  def update
    respond_to do |format|
      if @appointment.update(appointment_params)
        format.html { redirect_to @appointment, notice: "Appointment was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to @appointment, notice: "Appointment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
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
      params.expect(appointment: [ :patient_id, :user_id, :source, :booking_type, :starts_at, :ends_at, :status, :operatory, :notes ])
    end

    def parse_selected_date(raw_date)
      return if raw_date.blank?

      Date.iso8601(raw_date)
    rescue ArgumentError
      nil
    end
end
