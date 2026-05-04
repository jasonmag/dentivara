module Api
  module V1
    class PaymentsController < BaseController
      before_action :set_payment, only: %i[show update destroy]

      def index
        render json: Payment.order(paid_on: :desc)
      end

      def show
        render json: @payment
      end

      def create
        payment = Payment.new(payment_params)
        if payment.save
          render json: payment, status: :created
        else
          render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @payment.update(payment_params)
          render json: @payment
        else
          render json: { errors: @payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @payment.destroy
        head :no_content
      end

      private

      def set_payment
        @payment = Payment.find(params[:id])
      end

      def payment_params
        params.require(:payment).permit(:invoice_id, :amount, :paid_on, :method, :reference_code)
      end
    end
  end
end
