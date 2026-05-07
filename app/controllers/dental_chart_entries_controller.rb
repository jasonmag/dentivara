class DentalChartEntriesController < ApplicationController
  require "base64"
  require "stringio"

  before_action -> { require_roles(:clinic_owner, :system_admin, :dentist, :receptionist) }
  before_action :set_patient

  def create
    entry = @patient.dental_chart_entries.new(dental_chart_entry_params.except(:annotated_image_data, :surface_marks_data))
    entry.user = current_user
    entry.surface_marks = parse_surface_marks
    attach_annotated_image(entry)

    if entry.save
      redirect_to @patient, notice: "Dental chart entry added."
    else
      redirect_to @patient, alert: entry.errors.full_messages.to_sentence
    end
  end

  private

  def set_patient
    @patient = Patient.find(params.expect(:patient_id))
  end

  def dental_chart_entry_params
    params.expect(dental_chart_entry: %i[tooth_code entry_type notes recorded_on chart_image annotated_image_data surface_marks_data])
  end

  def parse_surface_marks
    raw = params.dig(:dental_chart_entry, :surface_marks_data).to_s
    return [] if raw.blank?

    parsed = JSON.parse(raw)
    return [] unless parsed.is_a?(Array)

    parsed
      .select { |item| item.is_a?(Hash) }
      .map do |item|
        {
          "tooth" => item["tooth"].to_s,
          "surface" => item["surface"].to_s,
          "status" => item["status"].to_s
        }
      end
      .select { |item| item["tooth"].present? && item["surface"].present? && item["status"].present? }
  rescue JSON::ParserError
    []
  end

  def attach_annotated_image(entry)
    return if entry.chart_image.attached?

    data_url = params.dig(:dental_chart_entry, :annotated_image_data).to_s
    return if data_url.blank?

    match = data_url.match(%r{\Adata:(image\/png|image\/jpeg|image\/jpg|image\/webp);base64,(.+)\z}m)
    return unless match

    content_type = match[1]
    encoded_data = match[2]
    decoded_data = Base64.decode64(encoded_data)
    extension = case content_type
                when "image/png" then "png"
                when "image/webp" then "webp"
                else "jpg"
                end

    entry.chart_image.attach(
      io: StringIO.new(decoded_data),
      filename: "chart-annotated-#{Time.current.to_i}.#{extension}",
      content_type: content_type
    )
  rescue ArgumentError
    nil
  end
end
