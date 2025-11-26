require "test_helper"

class BrandingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get brandings_show_url
    assert_response :success
  end

  test "should get edit" do
    get brandings_edit_url
    assert_response :success
  end

  test "should get update" do
    get brandings_update_url
    assert_response :success
  end
end
