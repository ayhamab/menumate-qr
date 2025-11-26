require "test_helper"

class Admin::DietaryTrendsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_dietary_trends_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_dietary_trends_show_url
    assert_response :success
  end

  test "should get create" do
    get admin_dietary_trends_create_url
    assert_response :success
  end

  test "should get generate_report" do
    get admin_dietary_trends_generate_report_url
    assert_response :success
  end

  test "should get dashboard" do
    get admin_dietary_trends_dashboard_url
    assert_response :success
  end
end
