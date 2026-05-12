module Api
  module V1
    class PaymentSerializer
      def self.call(payment, include_invoice: true)
        payload = {
          id: payment.id,
          invoice_id: payment.invoice_id,
          amount: payment.amount,
          paid_on: payment.paid_on,
          method: payment.method,
          reference_code: payment.reference_code,
          notes: payment.notes,
          recorded_by_user_id: payment.recorded_by_user_id,
          recorded_by: AppointmentSerializer.compact_user(payment.recorded_by),
          created_at: payment.created_at,
          updated_at: payment.updated_at
        }

        if include_invoice
          payload[:invoice] = {
            id: payment.invoice.id,
            invoice_number: payment.invoice.invoice_number,
            status: payment.invoice.status,
            total_amount: payment.invoice.total_amount,
            balance_amount: payment.invoice.balance_amount
          }
        end

        payload
      end
    end
  end
end
