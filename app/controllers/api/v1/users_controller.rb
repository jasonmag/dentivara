module Api
  module V1
    class UsersController < BaseController
      def index
        users = scoped_users.order(updated_at: :desc)
        if params[:search].present?
          query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search].to_s.downcase)}%"
          users = users.where("LOWER(users.name) LIKE :query OR LOWER(users.email) LIKE :query OR LOWER(users.role) LIKE :query", query: query)
        end

        render_collection(users, serializer: UserSerializer)
      end

      private

      def scoped_users
        return User.none if current_user&.patient?
        return User.all if current_user&.system_admin?

        User
          .joins(:clinic_memberships)
          .where(clinic_memberships: { clinic_id: current_user.accessible_clinics.select(:id) })
          .where.not(role: [ :patient, :system_admin ])
          .distinct
      end
    end
  end
end
