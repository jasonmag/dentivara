class ClinicSettingsController < ApplicationController
  before_action -> { require_permission!(:users, :view) }, only: :show
  before_action -> { require_permission!(:users, :update) }, only: :update

  def show
    @clinic_setting = ClinicSetting.current
  end

  def update
    @clinic_setting = ClinicSetting.current

    if @clinic_setting.update(clinic_setting_params)
      redirect_to clinic_settings_path, notice: "Clinic settings were saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def clinic_setting_params
    params.expect(clinic_setting: [ :time_zone ])
  end
end
