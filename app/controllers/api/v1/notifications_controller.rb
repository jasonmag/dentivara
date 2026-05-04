module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: %i[show update destroy]

      def index
        render json: Notification.order(scheduled_for: :asc)
      end

      def show
        render json: @notification
      end

      def create
        notification = Notification.new(notification_params)
        if notification.save
          render json: notification, status: :created
        else
          render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @notification.update(notification_params)
          render json: @notification
        else
          render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @notification.destroy
        head :no_content
      end

      private

      def set_notification
        @notification = Notification.find(params[:id])
      end

      def notification_params
        params.require(:notification).permit(:patient_id, :channel, :category, :scheduled_for, :sent_at, :status, :message)
      end
    end
  end
end
