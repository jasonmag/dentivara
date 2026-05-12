require "test_helper"

class DentalChartEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = patients(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "creates entry with annotation virtual field without unknown attribute error" do
    assert_difference("DentalChartEntry.count", 1) do
      post patient_dental_chart_entries_url(@patient), params: {
        dental_chart_entry: {
          recorded_on: Date.current,
          tooth_code: "16",
          entry_type: "exam",
          notes: "Occlusal caries noted",
          annotated_image_data: ""
        }
      }
    end

    entry = DentalChartEntry.order(:id).last
    assert_equal "16", entry.tooth_code
    assert_redirected_to patient_url(@patient)
  end
end
