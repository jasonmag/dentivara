class ClinicOnboarding
  DEFAULT_SERVICES = [
    [ "Routine Checkup", "General oral check and consultation", 1200, 30, "#2a9d8f" ],
    [ "Teeth Cleaning", "Full prophylaxis cleaning service", 2500, 45, "#0ea5e9" ],
    [ "Tooth Extraction", "Simple tooth extraction", 3000, 45, "#64748b" ]
  ].freeze

  def self.create!(clinic_params:, owner_params:, account_params: {})
    new(clinic_params: clinic_params, owner_params: owner_params, account_params: account_params).create!
  end

  def initialize(clinic_params:, owner_params:, account_params: {})
    @clinic_params = clinic_params
    @owner_params = owner_params
    @account_params = account_params
  end

  def create!
    Clinic.transaction do
      account = Account.create!(
        name: account_params[:name].presence || "#{clinic_params.fetch(:name)} Account",
        slug: account_params[:slug].presence || "#{clinic_params[:slug].presence || clinic_params.fetch(:name).parameterize}-account",
        billing_email: account_params[:billing_email].presence || clinic_params[:contact_email].presence || owner_params.fetch(:email),
        subscription_plan: account_params[:subscription_plan].presence || clinic_params[:subscription_plan].presence || "starter",
        subscription_status: account_params[:subscription_status].presence || "trialing",
        subscription_starts_on: account_params[:subscription_starts_on],
        subscription_ends_on: account_params[:subscription_ends_on],
        trial_ends_on: account_params[:trial_ends_on]
      )

      clinic = Clinic.create!(
        account: account,
        name: clinic_params.fetch(:name),
        slug: clinic_params[:slug],
        contact_email: clinic_params[:contact_email].presence || owner_params.fetch(:email),
        phone: clinic_params[:phone],
        subscription_plan: clinic_params[:subscription_plan].presence || "starter",
        subscription_status: "trialing"
      )

      Current.set(clinic: clinic) do
        ClinicSetting.create!(
          clinic: clinic,
          time_zone: clinic_params[:time_zone].presence || ClinicSetting::DEFAULT_TIME_ZONE,
          currency_code: clinic_params[:currency_code].presence || "PHP",
          currency_locale: ClinicSetting::DEFAULT_CURRENCY_LOCALE
        )

        DEFAULT_SERVICES.each do |name, description, price, minutes, color|
          ClinicService.create!(
            clinic: clinic,
            name: name,
            description: description,
            base_price: price,
            duration_minutes: minutes,
            preparation_minutes: [ 5, (minutes * 0.2).round ].max,
            color: color,
            active: true
          )
        end
      end

      owner = User.create!(
        clinic: clinic,
        name: owner_params.fetch(:name),
        email: owner_params.fetch(:email).to_s.downcase,
        password: owner_params.fetch(:password),
        password_confirmation: owner_params.fetch(:password),
        role: :clinic_owner
      )
      owner.account_memberships.find_or_create_by!(account: account) do |membership|
        membership.role = "owner"
        membership.accepted_at = Time.current
      end
      [ clinic, owner ]
    end
  end

  private

  attr_reader :clinic_params, :owner_params, :account_params
end
