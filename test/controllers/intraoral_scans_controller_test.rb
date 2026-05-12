require "test_helper"

class IntraoralScansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = patients(:one)
    sign_in_as(users(:one))
  end

  test "creates intraoral scan with stl upload" do
    file = fixture_file_upload("sample_scan.stl", "application/octet-stream")

    assert_difference("IntraoralScan.count", 1) do
      post patient_intraoral_scans_url(@patient), params: {
        intraoral_scan: {
          captured_on: Date.current,
          scan_type: "intraoral_scan",
          notes: "Upper arch scan",
          scan_file: file
        }
      }
    end

    scan = IntraoralScan.order(:id).last
    assert scan.scan_file.attached?
    assert scan.viewable_3d?
    assert_redirected_to patient_url(@patient)
  end

  test "shows intraoral scan viewer page" do
    scan = @patient.intraoral_scans.new(
      user: users(:one),
      captured_on: Date.current,
      scan_type: "upper_arch",
      notes: "STL scan"
    )
    scan.scan_file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sample_scan.stl")),
      filename: "sample_scan.stl",
      content_type: "application/octet-stream"
    )
    scan.save!

    get patient_intraoral_scan_url(@patient, scan)

    assert_response :success
    assert_match "3D Preview", response.body
    assert_match "intraoral-scan-viewer", response.body
  end
end
