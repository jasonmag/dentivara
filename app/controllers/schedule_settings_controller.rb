class ScheduleSettingsController < ApplicationController
  before_action -> { require_permission!(:appointments, :view) }, only: :show
  before_action -> { require_permission!(:appointments, :update) }, except: :show

  def show
    load_schedule_settings
  end

  def create_clinic_schedule
    schedule = ClinicSchedule.find_or_initialize_by(day_of_week: clinic_schedule_params[:day_of_week])
    schedule.assign_attributes(clinic_schedule_params)

    if schedule.save
      redirect_to schedule_settings_path, notice: "Clinic schedule was saved."
    else
      redirect_to schedule_settings_path, alert: schedule.errors.full_messages.to_sentence
    end
  end

  def destroy_clinic_schedule
    ClinicSchedule.find(params[:id]).destroy!
    redirect_to schedule_settings_path, notice: "Clinic schedule was removed."
  end

  def create_clinic_closure
    closure = ClinicClosure.find_or_initialize_by(date: clinic_closure_params[:date])
    closure.assign_attributes(clinic_closure_params)

    if closure.save
      redirect_to schedule_settings_path, notice: "Clinic closure was saved."
    else
      redirect_to schedule_settings_path, alert: closure.errors.full_messages.to_sentence
    end
  end

  def destroy_clinic_closure
    ClinicClosure.find(params[:id]).destroy!
    redirect_to schedule_settings_path, notice: "Clinic closure was removed."
  end

  def create_dentist_schedule
    schedule = DentistSchedule.new(dentist_schedule_params)

    if schedule.save
      redirect_to schedule_settings_path, notice: "Dentist schedule was saved."
    else
      redirect_to schedule_settings_path, alert: schedule.errors.full_messages.to_sentence
    end
  end

  def destroy_dentist_schedule
    DentistSchedule.find(params[:id]).destroy!
    redirect_to schedule_settings_path, notice: "Dentist schedule was removed."
  end

  def create_dentist_override
    override = DentistScheduleOverride.find_or_initialize_by(
      user_id: dentist_override_params[:user_id],
      date: dentist_override_params[:date]
    )
    override.assign_attributes(dentist_override_params)

    if override.save
      redirect_to schedule_settings_path, notice: "Dentist override was saved."
    else
      redirect_to schedule_settings_path, alert: override.errors.full_messages.to_sentence
    end
  end

  def destroy_dentist_override
    DentistScheduleOverride.find(params[:id]).destroy!
    redirect_to schedule_settings_path, notice: "Dentist override was removed."
  end

  private

  def load_schedule_settings
    @clinic_schedules = ClinicSchedule.order(:day_of_week)
    @clinic_closures = ClinicClosure.order(date: :desc).limit(20)
    @dentist_schedules = DentistSchedule.includes(:user).joins(:user).order(:day_of_week, "users.name", :starts_at)
    @dentist_overrides = DentistScheduleOverride.includes(:user).order(date: :desc).limit(20)
    @dentists = User.dentist.order(:name)
  end

  def clinic_schedule_params
    params.expect(clinic_schedule: [ :day_of_week, :opens_at, :closes_at, :closed, :emergency_only, :max_concurrent_appointments ])
  end

  def clinic_closure_params
    params.expect(clinic_closure: [ :date, :reason, :emergency_only ])
  end

  def dentist_schedule_params
    params.expect(dentist_schedule: [ :user_id, :day_of_week, :starts_at, :ends_at, :active ])
  end

  def dentist_override_params
    params.expect(dentist_schedule_override: [ :user_id, :date, :available_from, :available_until, :unavailable, :reason ])
  end
end
