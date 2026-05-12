module Api
  module V1
    class NotificationsController < BaseController
      before_action -> { authorize_api!(:notifications) }
      before_action :set_notification, only: %i[show update destroy]

      def index
        notifications = Notification.includes(:patient).order(scheduled_for: :asc)
        notifications = notifications.where(patient_id: params[:patient_id]) if params[:patient_id].present?
        notifications = notifications.where(status: params[:status]) if params[:status].present?
        notifications = notifications.where(category: params[:category]) if params[:category].present?
        notifications = notifications.where(channel: params[:channel]) if params[:channel].present?

        render_collection(notifications, serializer: NotificationSerializer)
      end

      def show
        render_resource(@notification, serializer: NotificationSerializer)
      end

      def create
        notification = Notification.new(notification_params)
        if notification.save
          render_resource(notification, serializer: NotificationSerializer, status: :created)
        else
          render_validation_errors(notification)
        end
      end

      def update
        if @notification.update(notification_params)
          render_resource(@notification, serializer: NotificationSerializer)
        else
          render_validation_errors(@notification)
        end
      end

      def destroy
        @notification.destroy
        head :no_content
      end

      private

      def set_notification
        @notification = Notification.includes(:patient).find(params[:id])
      end

      def notification_params
        params.require(:notification).permit(:patient_id, :channel, :category, :scheduled_for, :sent_at, :status, :message)
      end
    end
  end
end
