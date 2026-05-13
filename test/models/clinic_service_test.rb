require "test_helper"

class ClinicServiceTest < ActiveSupport::TestCase
  test "requires a hex color" do
    service = ClinicService.new(
      name: "Implant Consultation",
      base_price: 2500,
      duration_minutes: 45,
      preparation_minutes: 5,
      color: "teal"
    )

    assert_not service.valid?
    assert_includes service.errors[:color], "is invalid"

    service.color = "#2a9d8f"

    assert service.valid?
  end
end
