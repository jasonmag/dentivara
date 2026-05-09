module Api
  module V1
    class PaymentsController < BaseController
      require "digest"

      before_action :set_payment, only: %i[show update destroy]

      def index
        render json: Payment.order(paid_on: :desc)
      end

      def show
        render json: @payment
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
        if payment.save
          render json: payment, status: :created
        else
          render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def create_with_idempotency
        payment = Payment.new(payment_params)
        saved = payment.save
        status = saved ? :created : :unprocessable_entity
        body = saved ? payment.as_json : { errors: payment.errors.full_messages }

        record_response!(status: Rack::Utils.status_code(status), body: body)

        render json: body, status: status
      rescue ActiveRecord::RecordNotUnique
        replay = ApiIdempotencyKey.find_by(key: idempotency_key, http_method: request.method, path: request.path)
        return render_replay(replay) if replay.present?

        render json: { error: "Could not complete idempotent request" }, status: :conflict
      end

      def find_idempotency_replay
        existing = ApiIdempotencyKey.find_by(key: idempotency_key, http_method: request.method, path: request.path)
        return nil if existing.blank?

        if existing.request_hash != idempotency_request_hash
          render json: { error: "Idempotency key reuse with different request payload" }, status: :conflict
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
        @payment = Payment.find(params[:id])
      end

      def payment_params
        params.require(:payment).permit(:invoice_id, :amount, :paid_on, :method, :reference_code, :notes, :recorded_by_user_id)
      end
    end
  end
end
