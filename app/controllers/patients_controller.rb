class PatientsController < ApplicationController
  include AccessTrackable

  before_action :set_patient, only: %i[ show edit update destroy ]
  before_action -> { require_permission!(:patients, :view) }, only: %i[index show]
  before_action -> { require_permission!(:patients, :create) }, only: %i[new create]
  before_action -> { require_permission!(:patients, :update) }, only: %i[edit update]
  before_action -> { require_permission!(:patients, :destroy) }, only: :destroy

  # GET /patients or /patients.json
  def index
    @search_query = params[:search].to_s.strip
    @patients = Patient.order(updated_at: :desc)
    if @search_query.present?
      q = Patient.sanitize_sql_like(@search_query.downcase)
      contains_term = "%#{q}%"
      starts_term = "#{q}%"

      email_user_sql = "LOWER(CASE WHEN INSTR(COALESCE(email, ''), '@') > 0 THEN SUBSTR(COALESCE(email, ''), 1, INSTR(COALESCE(email, ''), '@') - 1) ELSE COALESCE(email, '') END)"
      full_name_sql = "LOWER(COALESCE(first_name, '') || ' ' || COALESCE(last_name, ''))"
      email_match_sql = @search_query.include?("@") ? "LOWER(COALESCE(email, ''))" : email_user_sql

      filter_conditions = [
        "LOWER(COALESCE(first_name, '')) LIKE :contains_term",
        "LOWER(COALESCE(last_name, '')) LIKE :contains_term",
        "#{full_name_sql} LIKE :contains_term",
        "LOWER(COALESCE(phone, '')) LIKE :contains_term",
        "LOWER(COALESCE(emergency_contact_name, '')) LIKE :contains_term",
        "LOWER(COALESCE(emergency_contact_phone, '')) LIKE :contains_term",
        "#{email_match_sql} LIKE :contains_term"
      ]

      # Relevance ranking: prefix matches rank higher than contains matches.
      order_sql = <<~SQL.squish
        CASE
          WHEN #{full_name_sql} = :exact_term THEN 0
          WHEN LOWER(COALESCE(first_name, '')) LIKE :starts_term THEN 1
          WHEN LOWER(COALESCE(last_name, '')) LIKE :starts_term THEN 2
          WHEN #{full_name_sql} LIKE :starts_term THEN 3
          WHEN #{email_match_sql} LIKE :starts_term THEN 4
          WHEN LOWER(COALESCE(phone, '')) LIKE :starts_term THEN 5
          WHEN LOWER(COALESCE(emergency_contact_name, '')) LIKE :starts_term THEN 6
          WHEN LOWER(COALESCE(emergency_contact_phone, '')) LIKE :starts_term THEN 7
          ELSE 8
        END ASC,
        updated_at DESC
      SQL

      @patients = @patients
        .where(filter_conditions.join(" OR "), contains_term: contains_term)
        .order(Arel.sql(Patient.send(:sanitize_sql_array, [order_sql, exact_term: q, starts_term: starts_term])))
    end
    @active_treatment_count = TreatmentRecord.where(performed_on: 30.days.ago.to_date..Date.current).select(:patient_id).distinct.count
    @urgent_cases_count = Appointment.where(status: "confirmed").where("starts_at <= ?", 24.hours.from_now).count
    @attendance_rate = appointment_attendance_rate
  end

  # GET /patients/1 or /patients/1.json
  def show
    track_access!(resource: @patient, action: "view_patient")
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients or /patients.json
  def create
    @patient = Patient.new(patient_params)

    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: "Patient was successfully created." }
        format.turbo_stream { redirect_to @patient, notice: "Patient was successfully created." }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, formats: :html, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patients/1 or /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: "Patient was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to @patient, notice: "Patient was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, formats: :html, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1 or /patients/1.json
  def destroy
    @patient.destroy!

    respond_to do |format|
      format.html { redirect_to patients_path, notice: "Patient was successfully destroyed.", status: :see_other }
      format.turbo_stream { redirect_to patients_path, notice: "Patient was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def patient_params
      params.expect(patient: [
        :first_name, :last_name, :birth_date, :phone, :email,
        :emergency_contact_name, :emergency_contact_phone, :medical_history, :consented_at,
        :chief_complaint, :known_allergies, :current_medications, :medical_conditions, :last_dental_visit_on,
        :address_line1, :address_line2, :city, :state, :postal_code, :country, :preferred_contact_method,
        :insurance_provider, :insurance_policy_number, :dental_chart
      ])
    end

    def appointment_attendance_rate
      total = Appointment.where(starts_at: 30.days.ago..Time.current).count
      return 100 if total.zero?

      completed = Appointment.where(starts_at: 30.days.ago..Time.current, status: "completed").count
      ((completed.to_f / total) * 100).round
    end
end
