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

    if @clinic_service.save
      redirect_to @clinic_service, notice: "Service was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @clinic_service.update(clinic_service_params)
      redirect_to @clinic_service, notice: "Service was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @clinic_service.destroy!
    redirect_to clinic_services_path, notice: "Service was successfully deleted.", status: :see_other
  end

  private

  def set_clinic_service
    @clinic_service = ClinicService.find(params.expect(:id))
  end

  def clinic_service_params
    params.expect(clinic_service: %i[name description base_price active duration_minutes])
  end
end
