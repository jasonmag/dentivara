module Billing
  class AppointmentInvoiceSync
    Result = Struct.new(:invoice, :created, :updated, keyword_init: true) do
      def created?
        created
      end

      def updated?
        updated
      end
    end

    def self.call(appointment)
      new(appointment).call
    end

    def initialize(appointment)
      @appointment = appointment
    end

    def call
      return Result.new(invoice: current_invoice, created: false, updated: false) unless completed_appointment?

      ActiveRecord::Base.transaction do
        record = billing_treatment_record
        created_record = record.new_record?
        sync_treatment_record!(record)

        invoice = record.invoice || record.build_invoice
        created_invoice = invoice.new_record?
        changed = sync_invoice!(invoice, record)
        invoice.reload

        Result.new(invoice: invoice, created: created_invoice, updated: changed || created_record)
      end
    end

    private

    attr_reader :appointment

    def completed_appointment?
      appointment.status == "completed"
    end

    def current_invoice
      existing_billing_record&.invoice
    end

    def billing_treatment_record
      existing_billing_record || appointment.treatment_records.new
    end

    def existing_billing_record
      appointment.treatment_records.includes(:invoice).detect { |record| record.invoice.present? } ||
        appointment.treatment_records.order(created_at: :asc).first
    end

    def sync_treatment_record!(record)
      amount = appointment.clinic_service&.base_price || 0

      record.patient = appointment.patient
      record.user = appointment.user
      record.appointment = appointment
      record.service_type = appointment.clinic_service&.name.presence || appointment.booking_type.humanize
      record.performed_on = appointment.ends_at&.to_date || appointment.starts_at&.to_date || Time.zone.today
      record.clinical_notes = appointment.notes if appointment.notes.present? && record.clinical_notes.blank?
      record.cost = amount.to_d
      record.save! if record.new_record? || record.changed?
    end

    def sync_invoice!(invoice, record)
      total_amount = (appointment.clinic_service&.base_price || 0).to_d
      paid_total = invoice.payments.sum(:amount).to_d
      balance_amount = [ total_amount - paid_total, 0.to_d ].max
      next_status = if balance_amount.zero? && paid_total.positive?
        "paid"
      elsif paid_total.positive?
        "partially_paid"
      else
        "approved"
      end

      attributes = {
        patient: appointment.patient,
        treatment_record: record,
        status: next_status,
        total_amount: total_amount,
        balance_amount: balance_amount,
        issued_on: appointment.ends_at&.to_date || appointment.starts_at&.to_date || Time.zone.today
      }

      attributes[:approved_by_dentist_at] = invoice.approved_by_dentist_at || Time.current
      attributes[:approved_by_admin_at] = invoice.approved_by_admin_at || Time.current

      changed = invoice.new_record? || attributes.any? { |key, value| invoice.public_send(key) != value }
      invoice.assign_attributes(attributes)
      invoice.save!
      invoice.reload
      changed || invoice.invoice_number.blank?
    end
  end
end
