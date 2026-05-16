require "test_helper"

class ApiV1SubscriptionPlansTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = User.create!(
      clinic: clinics(:one),
      name: "Subscription Admin",
      email: "subscription-admin@example.com",
      role: :system_admin,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "system admin manages subscription plans" do
    get api_v1_subscription_plans_url, headers: api_headers_for(@system_admin), as: :json
    assert_response :success

    assert_difference("SubscriptionPlan.count", 1) do
      post api_v1_subscription_plans_url,
        headers: api_headers_for(@system_admin),
        params: {
          subscription_plan: {
            name: "Trial Plan",
            code: "trial_plan",
            price_per_month: 500,
            clinics_included: 1,
            extra_clinic_price: 250,
            active: true,
            position: 9
          }
        },
        as: :json
    end
    assert_response :created
    created_plan = response.parsed_body.fetch("data")
    assert_equal 500, created_plan.fetch("price_per_month")
    assert_equal 1, created_plan.fetch("clinics_included")
    assert_equal 250, created_plan.fetch("extra_clinic_price")
    assert created_plan.fetch("currency_code").present?

    plan = SubscriptionPlan.find_by!(code: "trial_plan")
    patch api_v1_subscription_plan_url(plan),
      headers: api_headers_for(@system_admin),
      params: { subscription_plan: { price_per_month: 600, active: false } },
      as: :json

    assert_response :success
    assert_equal 600, plan.reload.price_per_month
    assert_not plan.active

    assert_difference("SubscriptionPlan.count", -1) do
      delete api_v1_subscription_plan_url(plan), headers: api_headers_for(@system_admin), as: :json
    end
    assert_response :no_content
  end
end
