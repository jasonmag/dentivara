module Api
  module V1
    class PlatformOverviewController < BaseController
      before_action :require_system_admin!

      def show
        accounts = Account
          .includes(:account_memberships, :account_subscriptions, :members, clinics: [ :clinic_memberships, :members ])
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
          client_number: account.client_number,
          name: account.name,
          billing_email: account.billing_email,
          subscription_plan: account.subscription_plan,
          subscription_status: account.subscription_status,
          subscription_starts_on: account.subscription_starts_on,
          subscription_ends_on: account.subscription_ends_on,
          clinic_allowance: account.clinic_allowance,
          trial_ends_on: account.trial_ends_on,
          owners: account.members.select(&:clinic_owner?).map { |owner| user_payload(owner) },
          users_count: account.members.distinct.count,
          subscriptions: account.account_subscriptions.recent_first.map { |subscription| subscription_payload(subscription) },
          clinics: account.clinics.order(:name).map { |clinic| clinic_payload(clinic) }
        }
      end

      def subscription_payload(subscription)
        {
          id: subscription.id,
          subscription_plan: subscription.subscription_plan,
          subscription_status: subscription.subscription_status,
          subscription_starts_on: subscription.subscription_starts_on,
          subscription_ends_on: subscription.subscription_ends_on,
          created_at: subscription.created_at
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
          archived_at: clinic.archived_at,
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
