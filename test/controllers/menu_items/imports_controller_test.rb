require "test_helper"

class MenuItems::ImportsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get menu_items_imports_new_url
    assert_response :success
  end

  test "should get create" do
    get menu_items_imports_create_url
    assert_response :success
  end
end
