require "test_helper"

class DietaryAccuracyReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get dietary_accuracy_reports_create_url
    assert_response :success
  end

  test "should get index" do
    get dietary_accuracy_reports_index_url
    assert_response :success
  end
end
