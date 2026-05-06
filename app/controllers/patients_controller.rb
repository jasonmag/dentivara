class PatientsController < ApplicationController
  include AccessTrackable

  before_action :set_patient, only: %i[ show edit update destroy ]

  # GET /patients or /patients.json
  def index
    @patients = Patient.order(updated_at: :desc)
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
        format.turbo_stream { render :new, status: :unprocessable_entity }
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
        format.turbo_stream { render :edit, status: :unprocessable_entity }
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
      params.expect(patient: [ :first_name, :last_name, :birth_date, :phone, :email, :emergency_contact_name, :emergency_contact_phone, :medical_history, :consented_at ])
    end

    def appointment_attendance_rate
      total = Appointment.where(starts_at: 30.days.ago..Time.current).count
      return 100 if total.zero?

      completed = Appointment.where(starts_at: 30.days.ago..Time.current, status: "completed").count
      ((completed.to_f / total) * 100).round
    end
end
