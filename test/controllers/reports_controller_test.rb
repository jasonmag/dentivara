require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = patients(:one)
    @user = users(:one)
    sign_in_as(@user)

    DentalChartEntry.create!(
      patient: @patient,
      user: @user,
      recorded_on: Date.current,
      tooth_code: "16",
      entry_type: "exam",
      notes: "Marked surfaces",
      surface_marks: [
        { "tooth" => "16", "surface" => "O", "status" => "caries" },
        { "tooth" => "16", "surface" => "M", "status" => "watch" }
      ]
    )
  end

  test "shows dental surface report" do
    get dental_chart_surfaces_report_url
    assert_response :success
    assert_includes response.body, "Dental Surface Report"
  end

  test "filters report by status and tooth" do
    get dental_chart_surfaces_report_url, params: { status: "caries", tooth: "16", surface: "O" }
    assert_response :success
    assert_includes response.body, "16-O"
    assert_includes response.body, "Caries"
  end
end
