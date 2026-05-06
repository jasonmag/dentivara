class TreatmentRecordsController < ApplicationController
  include AccessTrackable

  before_action :set_treatment_record, only: %i[ show edit update destroy ]

  # GET /treatment_records or /treatment_records.json
  def index
    @treatment_records = TreatmentRecord.includes(:patient, :user, :appointment).order(performed_on: :desc)
  end

  # GET /treatment_records/1 or /treatment_records/1.json
  def show
    track_access!(resource: @treatment_record, action: "view_treatment_record")
  end

  # GET /treatment_records/new
  def new
    @treatment_record = TreatmentRecord.new
  end

  # GET /treatment_records/1/edit
  def edit
  end

  # POST /treatment_records or /treatment_records.json
  def create
    @treatment_record = TreatmentRecord.new(treatment_record_params)

    respond_to do |format|
      if @treatment_record.save
        format.html { redirect_to @treatment_record, notice: "Treatment record was successfully created." }
        format.turbo_stream { redirect_to @treatment_record, notice: "Treatment record was successfully created." }
        format.json { render :show, status: :created, location: @treatment_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json { render json: @treatment_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /treatment_records/1 or /treatment_records/1.json
  def update
    respond_to do |format|
      if @treatment_record.update(treatment_record_params)
        format.html { redirect_to @treatment_record, notice: "Treatment record was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to @treatment_record, notice: "Treatment record was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @treatment_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.json { render json: @treatment_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /treatment_records/1 or /treatment_records/1.json
  def destroy
    @treatment_record.destroy!

    respond_to do |format|
      format.html { redirect_to treatment_records_path, notice: "Treatment record was successfully destroyed.", status: :see_other }
      format.turbo_stream { redirect_to treatment_records_path, notice: "Treatment record was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_treatment_record
      @treatment_record = TreatmentRecord.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def treatment_record_params
      params.expect(treatment_record: [ :patient_id, :user_id, :appointment_id, :service_type, :clinical_notes, :cost, :performed_on, clinical_files: [] ])
    end
end
