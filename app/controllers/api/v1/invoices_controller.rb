module Api
  module V1
    class InvoicesController < BaseController
      before_action :set_invoice, only: %i[show update destroy]

      def index
        invoices = Invoice.includes(:patient, :payments).order(updated_at: :desc)
        render json: invoices.as_json(include: { patient: { only: %i[id first_name last_name] }, payments: { only: %i[id amount paid_on method reference_code] } })
      end

      def show
        render json: @invoice.as_json(include: :payments)
      end

      def create
        invoice = Invoice.new(invoice_params)
        if invoice.save
          render json: invoice, status: :created
        else
          render json: { errors: invoice.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @invoice.update(invoice_params)
          render json: @invoice
        else
          render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @invoice.destroy
        head :no_content
      end

      private

      def set_invoice
        @invoice = Invoice.find(params[:id])
      end

      def invoice_params
        params.require(:invoice).permit(:patient_id, :treatment_record_id, :status, :total_amount, :balance_amount, :issued_on, :approved_by_dentist_at, :approved_by_admin_at)
      end
    end
  end
end
