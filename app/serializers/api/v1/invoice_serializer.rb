module Api
  module V1
    class InvoiceSerializer
      def self.call(invoice)
        {
          id: invoice.id,
          invoice_number: invoice.invoice_number,
          patient_id: invoice.patient_id,
          treatment_record_id: invoice.treatment_record_id,
          status: invoice.status,
          total_amount: invoice.total_amount,
          balance_amount: invoice.balance_amount,
          issued_on: invoice.issued_on,
          approved_by_dentist_at: invoice.approved_by_dentist_at,
          approved_by_admin_at: invoice.approved_by_admin_at,
          total_paid: invoice.total_paid,
          credit_amount: invoice.credit_amount,
          payment_progress_percentage: invoice.payment_progress_percentage,
          patient: AppointmentSerializer.compact_patient(invoice.patient),
          payments: invoice.payments.map { |payment| PaymentSerializer.call(payment, include_invoice: false) },
          created_at: invoice.created_at,
          updated_at: invoice.updated_at
        }
      end
    end
  end
end
