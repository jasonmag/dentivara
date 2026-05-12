class IntraoralScansController < ApplicationController
  include AccessTrackable

  before_action :set_patient
  before_action :set_intraoral_scan, only: %i[show destroy]
  before_action -> { require_permission!(:patients, :view) }, only: :show
  before_action -> { require_permission!(:patients, :update) }, only: %i[create destroy]

  def show
    track_access!(resource: @intraoral_scan, action: "view_intraoral_scan")
  end

  def create
    scan = @patient.intraoral_scans.new(intraoral_scan_params)
    scan.user = current_user

    if scan.save
      redirect_to patient_path(@patient), notice: "Intra-oral scan uploaded."
    else
      redirect_to patient_path(@patient), alert: scan.errors.full_messages.to_sentence
    end
  end

  def destroy
    @intraoral_scan.destroy!
    redirect_to patient_path(@patient), notice: "Intra-oral scan removed."
  end

  private

  def set_patient
    @patient = Patient.find(params.expect(:patient_id))
  end

  def set_intraoral_scan
    @intraoral_scan = @patient.intraoral_scans.find(params.expect(:id))
  end

  def intraoral_scan_params
    params.expect(intraoral_scan: [ :captured_on, :scan_type, :notes, :scan_file ])
  end
end
