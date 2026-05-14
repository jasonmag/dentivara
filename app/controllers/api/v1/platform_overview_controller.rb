module Api
  module V1
    class PlatformOverviewController < BaseController
      before_action :require_system_admin!

      def show
        accounts = Account
          .includes(:account_memberships, :members, clinics: [ :clinic_memberships, :members ])
          .order(created_at: :desc)

        render json: {
          data: {
            totals: totals,
            accounts: accounts.map { |account| account_payload(account) }
          }
        }
      end

      private

      def require_system_admin!
        return if current_user&.system_admin?

        render_error("forbidden", "Only system admins can view the platform overview.", status: :forbidden)
      end

      def totals
        {
          accounts: Account.count,
          clinics: Clinic.count,
          users: User.count,
          owners: User.clinic_owner.count,
          active_subscriptions: Account.where(subscription_status: %w[trialing active past_due]).count
        }
      end

      def account_payload(account)
        {
          id: account.id,
          name: account.name,
          billing_email: account.billing_email,
          subscription_plan: account.subscription_plan,
          subscription_status: account.subscription_status,
          subscription_starts_on: account.subscription_starts_on,
          subscription_ends_on: account.subscription_ends_on,
          trial_ends_on: account.trial_ends_on,
          owners: account.members.select(&:clinic_owner?).map { |owner| user_payload(owner) },
          users_count: account.members.distinct.count,
          clinics: account.clinics.order(:name).map { |clinic| clinic_payload(clinic) }
        }
      end

      def clinic_payload(clinic)
        {
          id: clinic.id,
          name: clinic.name,
          slug: clinic.slug,
          contact_email: clinic.contact_email,
          subscription_plan: clinic.subscription_plan,
          subscription_status: clinic.subscription_status,
          users_count: clinic.members.distinct.count,
          owners: clinic.members.select(&:clinic_owner?).map { |owner| user_payload(owner) },
          staff: clinic.members.reject { |member| member.clinic_owner? || member.system_admin? }.map { |member| user_payload(member) }
        }
      end

      def user_payload(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      end
    end
  end
end
