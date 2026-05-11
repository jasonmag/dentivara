module Api
  module V1
    class InvoicesController < BaseController
      before_action -> { authorize_api!(:invoices) }
      before_action :set_invoice, only: %i[show update destroy]

      def index
        invoices = Invoice.includes(:patient, :payments).order(updated_at: :desc)
        invoices = invoices.where(patient_id: params[:patient_id]) if params[:patient_id].present?
        invoices = invoices.where(status: params[:status]) if params[:status].present?
        invoices = invoices.where("issued_on >= ?", params[:issued_from]) if params[:issued_from].present?
        invoices = invoices.where("issued_on <= ?", params[:issued_to]) if params[:issued_to].present?

        render_collection(invoices, serializer: InvoiceSerializer)
      end

      def show
        render_resource(@invoice, serializer: InvoiceSerializer)
      end

      def create
        invoice = Invoice.new(invoice_params)
        if invoice.save
          render_resource(invoice, serializer: InvoiceSerializer, status: :created)
        else
          render_validation_errors(invoice)
        end
      end

      def update
        if @invoice.update(invoice_params)
          render_resource(@invoice, serializer: InvoiceSerializer)
        else
          render_validation_errors(@invoice)
        end
      end

      def destroy
        @invoice.destroy
        head :no_content
      end

      private

      def set_invoice
        @invoice = Invoice.includes(:patient, :payments).find(params[:id])
      end

      def invoice_params
        params.require(:invoice).permit(:patient_id, :treatment_record_id, :status, :total_amount, :balance_amount, :issued_on, :approved_by_dentist_at, :approved_by_admin_at)
      end
    end
  end
end
