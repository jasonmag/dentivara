class ReportsController < ApplicationController
  before_action -> { require_roles(:clinic_owner, :system_admin, :dentist, :receptionist) }

  def dental_chart_surfaces
    @status_filter = params[:status].to_s.strip
    @tooth_filter = params[:tooth].to_s.strip
    @surface_filter = params[:surface].to_s.strip.upcase

    entries = DentalChartEntry.includes(:patient, :user).order(recorded_on: :desc, created_at: :desc).limit(1000)

    @matched_rows = entries.filter_map do |entry|
      marks = Array(entry.surface_marks)
      matched_marks = marks.select do |mark|
        mark_status = mark["status"].to_s
        mark_tooth = mark["tooth"].to_s
        mark_surface = mark["surface"].to_s.upcase

        (@status_filter.blank? || mark_status == @status_filter) &&
          (@tooth_filter.blank? || mark_tooth == @tooth_filter) &&
          (@surface_filter.blank? || mark_surface == @surface_filter)
      end

      next if matched_marks.empty?

      {
        patient: entry.patient,
        entry: entry,
        recorded_by: entry.user,
        marks: matched_marks
      }
    end
  end
end
