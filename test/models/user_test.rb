require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "staff users default to full access while patients do not" do
    dentist = User.new(name: "Dr. Access", email: "access-dentist@example.com", role: :dentist)
    patient = User.new(name: "Patient Access", email: "access-patient@example.com", role: :patient)

    assert dentist.can_access?(:patients, :create)
    assert dentist.can_access?(:document_templates, :destroy)
    assert_not patient.can_access?(:patients, :view)
    assert_not patient.can_access?(:appointments, :create)
  end

  test "role permissions override the defaults" do
    RolePermission.create!(
      role: :dentist,
      permissions: {
        patients: { view: true, create: false, update: false, destroy: false },
        appointments: { view: true, create: false, update: false, destroy: false }
      }
    )

    user = User.new(name: "Limited User", email: "limited@example.com", role: :dentist)

    assert user.can_access?(:patients, :view)
    assert_not user.can_access?(:patients, :create)
    assert_not user.can_access?(:appointments, :destroy)
  end
end
