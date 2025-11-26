require "test_helper"

class Api::V1::DietaryTrendsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_dietary_trends_index_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_dietary_trends_show_url
    assert_response :success
  end

  test "should get summary" do
    get api_v1_dietary_trends_summary_url
    assert_response :success
  end

  test "should get export" do
    get api_v1_dietary_trends_export_url
    assert_response :success
  end
end
