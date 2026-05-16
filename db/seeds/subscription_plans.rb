# frozen_string_literal: true

starting_subscription_options = [
  {
    name: "Founding Clinic",
    code: "founding_clinic",
    price_per_month: 990,
    clinics_included: 2,
    extra_clinic_price: 500,
    position: 1
  },
  {
    name: "Starter",
    code: "starter",
    price_per_month: 1490,
    clinics_included: 1,
    extra_clinic_price: 700,
    position: 2
  },
  {
    name: "Growing",
    code: "growing",
    price_per_month: 2990,
    clinics_included: 3,
    extra_clinic_price: 700,
    position: 3
  },
  {
    name: "Enterprise",
    code: "enterprise",
    price_per_month: nil,
    clinics_included: nil,
    extra_clinic_price: nil,
    position: 4
  }
]

starting_subscription_options.each do |attributes|
  plan = SubscriptionPlan.find_or_initialize_by(code: attributes.fetch(:code))
  plan.assign_attributes(attributes.merge(active: true))
  plan.save!
end
