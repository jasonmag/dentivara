module Billing
  class InvoicePdfRenderer
    def initialize(invoice)
      @invoice = invoice
    end

    def render
      Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        pdf.text safe_text("Dentivara Dental Clinic"), size: 18, style: :bold
        pdf.move_down 6
        pdf.text safe_text("Invoice #{invoice.invoice_number || "##{invoice.id}"}"), size: 14, style: :bold
        pdf.move_down 16

        pdf.text safe_text("Patient: #{invoice.patient.full_name}")
        pdf.text safe_text("Issued On: #{invoice.issued_on || "N/A"}")
        pdf.text safe_text("Status: #{invoice.status.humanize}")
        pdf.text safe_text("Currency: #{ClinicSetting.current_currency_code}")
        pdf.move_down 16

        pdf.table(
          [
            [safe_text("Description"), safe_text("Amount")],
            [safe_text("Invoice Total"), safe_text(amount(invoice.total_amount))],
            [safe_text("Total Paid"), safe_text(amount(invoice.total_paid))],
            [safe_text("Remaining Balance"), safe_text(amount(invoice.balance_amount))],
            [safe_text("Credit"), safe_text(amount(invoice.credit_amount))]
          ],
          width: pdf.bounds.width,
          header: true
        )

        pdf.move_down 20
        pdf.text safe_text("Payment History"), size: 12, style: :bold
        pdf.move_down 8

        rows = invoice.payments.order(paid_on: :asc, created_at: :asc).map do |payment|
          [
            safe_text(payment.paid_on&.strftime("%b %d, %Y") || "N/A"),
            safe_text(payment.method.present? ? payment.method.humanize : "N/A"),
            safe_text(amount(payment.amount)),
            safe_text(payment.reference_code.presence || "N/A"),
            safe_text(payment.recorded_by&.name || "N/A")
          ]
        end

        rows = [[safe_text("No payments recorded"), "-", "-", "-", "-"]] if rows.empty?
        pdf.table([[safe_text("Date"), safe_text("Method"), safe_text("Amount"), safe_text("Reference"), safe_text("Recorded By")]] + rows, width: pdf.bounds.width, header: true)
      end.render
    end

    private

    attr_reader :invoice

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
