class HomeController < ApplicationController
  skip_before_action :require_login, only: :index, raise: false

  def index
    @news_items = [
      {
        title: "Smart appointment reminders",
        detail: "Automated SMS and email reminders reduce no-shows and keep your chair time optimized."
      },
      {
        title: "New patient intake portal",
        detail: "Patients can now submit forms before arrival, cutting front-desk wait times."
      },
      {
        title: "Compliance visibility",
        detail: "Built-in audit logs and consent tracking help your clinic stay inspection-ready."
      }
    ]
  end

  def dashboard
    today = Time.zone.today
    selected_month = parse_month_param(params[:month]) || today
    month_start = selected_month.beginning_of_month
    month_end = selected_month.end_of_month
    calendar_start = month_start.beginning_of_week(:sunday)
    calendar_end = month_end.end_of_week(:sunday)

    @stats = {
      patients: Patient.count,
      appointments_today: Appointment.where(starts_at: today.all_day).count,
      treatments_this_month: TreatmentRecord.where(performed_on: month_start..month_end).count,
      outstanding_balance: Invoice.sum(:balance_amount)
    }

    @upcoming_appointments = Appointment.includes(:patient, :user).where(starts_at: Time.current..).order(:starts_at).limit(8)
    @recent_invoices = Invoice.includes(:patient).order(updated_at: :desc).limit(8)
    @calendar_days = (calendar_start..calendar_end).to_a
    @calendar_appointments_by_day = Appointment.includes(:patient, :user)
                                               .where(starts_at: calendar_start.beginning_of_day..calendar_end.end_of_day)
                                               .order(:starts_at)
                                               .group_by { |appointment| appointment.starts_at.to_date }
    @calendar_month_date = month_start
    @calendar_month_label = month_start.strftime("%B %Y")
    @previous_calendar_month = (month_start - 1.month).strftime("%Y-%m")
    @next_calendar_month = (month_start + 1.month).strftime("%Y-%m")
  end

  private

  def parse_month_param(raw_month)
    return if raw_month.blank?

    Date.strptime(raw_month, "%Y-%m")
  rescue ArgumentError
    nil
  end
end
