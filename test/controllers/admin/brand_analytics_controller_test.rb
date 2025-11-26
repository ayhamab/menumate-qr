require "test_helper"

class Admin::BrandAnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_brand_analytics_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_brand_analytics_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_brand_analytics_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_brand_analytics_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_brand_analytics_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_brand_analytics_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_brand_analytics_destroy_url
    assert_response :success
  end

  test "should get regenerate_api_key" do
    get admin_brand_analytics_regenerate_api_key_url
    assert_response :success
  end

  test "should get toggle_active" do
    get admin_brand_analytics_toggle_active_url
    assert_response :success
  end
end
