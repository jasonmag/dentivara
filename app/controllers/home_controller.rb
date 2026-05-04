class HomeController < ApplicationController
  def index
    today = Time.zone.today
    month_start = today.beginning_of_month
    month_end = today.end_of_month
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
    @calendar_month_label = month_start.strftime("%B %Y")
  end
end
