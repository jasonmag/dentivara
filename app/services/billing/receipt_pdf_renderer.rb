module Billing
  class ReceiptPdfRenderer
    def initialize(payment)
      @payment = payment
    end

    def render
      Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        pdf.text safe_text("Dentivara Dental Clinic"), size: 18, style: :bold
        pdf.move_down 6
        pdf.text safe_text("Official Receipt"), size: 14, style: :bold
        pdf.move_down 16

        pdf.text safe_text("Receipt ID: ##{payment.id}")
        pdf.text safe_text("Invoice: #{payment.invoice.invoice_number || "##{payment.invoice_id}"}")
        pdf.text safe_text("Patient: #{payment.invoice.patient.full_name}")
        pdf.text safe_text("Paid On: #{payment.paid_on || "N/A"}")
        pdf.text safe_text("Payment Method: #{payment.method.present? ? payment.method.humanize : "N/A"}")
        pdf.text safe_text("Reference: #{payment.reference_code.presence || "N/A"}")
        pdf.text safe_text("Recorded By: #{payment.recorded_by&.name || "N/A"}")
        pdf.move_down 12

        pdf.table(
          [
            [safe_text("Payment Amount"), safe_text(amount(payment.amount))],
            [safe_text("Remaining Invoice Balance"), safe_text(amount(payment.invoice.balance_amount))],
            [safe_text("Invoice Status"), safe_text(payment.invoice.status.humanize)]
          ],
          width: pdf.bounds.width
        )

        if payment.notes.present?
          pdf.move_down 14
          pdf.text safe_text("Notes"), style: :bold
          pdf.move_down 4
          pdf.text safe_text(payment.notes)
        end
      end.render
    end

    private

    attr_reader :payment

    def amount(value)
      helpers = ApplicationController.helpers
      config = ClinicSetting.current.currency_config
      formatted_number = helpers.number_with_precision(
        value.to_d,
        precision: 2,
        delimiter: config.fetch(:delimiter),
        separator: config.fetch(:separator)
      )
      "#{ClinicSetting.current_currency_code} #{formatted_number}"
    end

    def safe_text(value)
      value.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?").encode("UTF-8")
    end
  end
end
