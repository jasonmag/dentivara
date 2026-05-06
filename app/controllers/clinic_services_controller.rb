class ClinicServicesController < ApplicationController
  before_action :set_clinic_service, only: %i[show edit update destroy]
  before_action -> { require_roles(:clinic_owner, :system_admin, :receptionist, :dentist) }

  def index
    @clinic_services = ClinicService.order(:name)
  end

  def show; end

  def new
    @clinic_service = ClinicService.new
  end

  def edit; end

  def create
    @clinic_service = ClinicService.new(clinic_service_params)

    respond_to do |format|
      if @clinic_service.save
        format.html { redirect_to @clinic_service, notice: "Service was successfully created." }
        format.turbo_stream { redirect_to @clinic_service, notice: "Service was successfully created." }
        format.json { render :show, status: :created, location: @clinic_service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json { render json: @clinic_service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @clinic_service.update(clinic_service_params)
        format.html { redirect_to @clinic_service, notice: "Service was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to @clinic_service, notice: "Service was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @clinic_service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.json { render json: @clinic_service.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @clinic_service.destroy!
    respond_to do |format|
      format.html { redirect_to clinic_services_path, notice: "Service was successfully deleted.", status: :see_other }
      format.turbo_stream { redirect_to clinic_services_path, notice: "Service was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_clinic_service
    @clinic_service = ClinicService.find(params.expect(:id))
  end

  def clinic_service_params
    params.expect(clinic_service: %i[name description base_price active duration_minutes])
  end
end
