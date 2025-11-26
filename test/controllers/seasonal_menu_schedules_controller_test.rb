require "test_helper"

class SeasonalMenuSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get seasonal_menu_schedules_index_url
    assert_response :success
  end

  test "should get show" do
    get seasonal_menu_schedules_show_url
    assert_response :success
  end

  test "should get new" do
    get seasonal_menu_schedules_new_url
    assert_response :success
  end

  test "should get create" do
    get seasonal_menu_schedules_create_url
    assert_response :success
  end

  test "should get edit" do
    get seasonal_menu_schedules_edit_url
    assert_response :success
  end

  test "should get update" do
    get seasonal_menu_schedules_update_url
    assert_response :success
  end

  test "should get destroy" do
    get seasonal_menu_schedules_destroy_url
    assert_response :success
  end
end
