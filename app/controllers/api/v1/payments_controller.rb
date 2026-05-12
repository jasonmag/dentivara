module Api
  module V1
    class PaymentsController < BaseController
      require "digest"

      before_action -> { authorize_api!(:payments) }
      before_action :set_payment, only: %i[show update destroy]

      def index
        payments = Payment.includes(:invoice, :recorded_by).order(paid_on: :desc, id: :desc)
        payments = payments.where(invoice_id: params[:invoice_id]) if params[:invoice_id].present?
        payments = payments.where(method: params[:method]) if params[:method].present?
        payments = payments.where("paid_on >= ?", params[:paid_from]) if params[:paid_from].present?
        payments = payments.where("paid_on <= ?", params[:paid_to]) if params[:paid_to].present?

        render_collection(payments, serializer: PaymentSerializer)
      end

      def show
        render_resource(@payment, serializer: PaymentSerializer)
      end

      def create
        return create_without_idempotency if idempotency_key.blank?

        replay = find_idempotency_replay
        return render_replay(replay) if replay.present?

        create_with_idempotency
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

      def create_without_idempotency
        payment = Payment.new(payment_params)
        payment.recorded_by ||= current_user

        if payment.save
          render_resource(payment, serializer: PaymentSerializer, status: :created)
        else
          render_validation_errors(payment)
        end
      end

      def create_with_idempotency
        payment = Payment.new(payment_params)
        payment.recorded_by ||= current_user
        saved = payment.save
        status = saved ? :created : :unprocessable_entity
        body = saved ? { data: PaymentSerializer.call(payment) } : {
          error: {
            code: "validation_failed",
            message: "Validation failed.",
            details: payment.errors.to_hash(true)
          }
        }

        record_response!(status: Rack::Utils.status_code(status), body: body)

        render json: body, status: status
      rescue ActiveRecord::RecordNotUnique
        replay = ApiIdempotencyKey.find_by(key: idempotency_key, http_method: request.method, path: request.path)
        return render_replay(replay) if replay.present?

        render_error("idempotency_conflict", "Could not complete idempotent request.", status: :conflict)
      end

      def find_idempotency_replay
        existing = ApiIdempotencyKey.find_by(key: idempotency_key, http_method: request.method, path: request.path)
        return nil if existing.blank?

        if existing.request_hash != idempotency_request_hash
          render_error("idempotency_conflict", "Idempotency key reused with a different request payload.", status: :conflict)
          return :conflict_rendered
        end

        existing
      end

      def render_replay(replay)
        return if replay == :conflict_rendered

        render json: JSON.parse(replay.response_body), status: replay.response_code
      end

      def record_response!(status:, body:)
        ApiIdempotencyKey.create!(
          key: idempotency_key,
          http_method: request.method,
          path: request.path,
          request_hash: idempotency_request_hash,
          response_code: status,
          response_body: body.to_json,
          expires_at: 24.hours.from_now
        )
      end

      def idempotency_key
        @idempotency_key ||= request.headers["Idempotency-Key"].to_s.strip
      end

      def idempotency_request_hash
        @idempotency_request_hash ||= begin
          canonical_payload = payment_params.to_h.deep_stringify_keys.sort.to_h
          Digest::SHA256.hexdigest(canonical_payload.to_json)
        end
      end

      def set_payment
        @payment = Payment.includes(:invoice, :recorded_by).find(params[:id])
      end

      def payment_params
        params.require(:payment).permit(:invoice_id, :amount, :paid_on, :method, :reference_code, :notes, :recorded_by_user_id)
      end
    end
  end
end
