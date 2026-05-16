require "test_helper"

class ApiV1AccountSubscriptionsTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @owner.update!(role: :clinic_owner, password: "password123", password_confirmation: "password123")
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "Subscription Status Admin",
      email: "subscription-status-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
    [
      [ "Starter", "starter", 1490, 1, 700, 1 ],
      [ "Growing", "growing", 2990, 3, 700, 2 ]
    ].each do |name, code, price, clinics, extra_clinic, position|
      plan = SubscriptionPlan.find_or_initialize_by(code: code)
      plan.update!(
        name: name,
        price_per_month: price,
        clinics_included: clinics,
        extra_clinic_price: extra_clinic,
        active: true,
        position: position
      )
    end
  end

  test "clinic owner can request an inactive subscription" do
    assert_difference("AccountSubscription.count", 1) do
      post api_v1_account_subscription_url,
        headers: api_headers_for(@owner),
        params: {
          account_subscription: {
            subscription_plan: "growing"
          }
        },
        as: :json
    end

    assert_response :created
    account = accounts(:one).reload
    assert_equal "growing", account.subscription_plan
    assert_equal "inactive", account.subscription_status
    assert_equal "inactive", response.parsed_body.dig("data", "subscriptions", 0, "subscription_status")
    assert_equal "growing", response.parsed_body.dig("data", "subscriptions", 0, "subscription_plan")
  end

  test "clinic owner cannot activate their own subscription" do
    post api_v1_account_subscription_url,
      headers: api_headers_for(@owner),
      params: {
        account_subscription: {
          subscription_plan: "starter",
          subscription_status: "active"
        }
      },
      as: :json

    assert_response :created
    assert_equal "inactive", accounts(:one).reload.subscription_status
    assert_equal "inactive", response.parsed_body.dig("data", "subscriptions", 0, "subscription_status")
  end

  test "system admin can update subscription status" do
    subscription = accounts(:one).account_subscriptions.create!(
      subscription_plan: "growing",
      subscription_status: "inactive",
      subscription_starts_on: "2026-06-01",
      subscription_ends_on: "2027-06-01"
    )

    patch "/api/v1/account_subscriptions/#{subscription.id}",
      headers: api_headers_for(@system_admin),
      params: { account_subscription: { subscription_status: "active" } },
      as: :json

    assert_response :success
    assert_equal "active", subscription.reload.subscription_status
    assert_equal "active", accounts(:one).reload.subscription_status
    assert_equal "growing", accounts(:one).subscription_plan
  end
end
