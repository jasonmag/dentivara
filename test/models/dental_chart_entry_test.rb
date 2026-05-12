require "test_helper"

class DentalChartEntryTest < ActiveSupport::TestCase
  setup do
    @patient = patients(:one)
    @user = users(:one)
  end

  test "is invalid without notes and without image" do
    entry = DentalChartEntry.new(
      patient: @patient,
      user: @user,
      recorded_on: Date.current,
      entry_type: "exam",
      notes: ""
    )

    assert_not entry.valid?
    assert_includes entry.errors.full_messages, "Add notes or upload a chart image."
  end

  test "accepts array hash surface marks" do
    entry = DentalChartEntry.new(
      patient: @patient,
      user: @user,
      recorded_on: Date.current,
      entry_type: "exam",
      notes: "ok",
      surface_marks: [{ "tooth" => "16", "surface" => "O", "status" => "caries" }]
    )

    assert entry.valid?
  end
end
