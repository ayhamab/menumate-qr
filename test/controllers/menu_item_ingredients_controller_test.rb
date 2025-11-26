require "test_helper"

class MenuItemIngredientsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get menu_item_ingredients_index_url
    assert_response :success
  end

  test "should get create" do
    get menu_item_ingredients_create_url
    assert_response :success
  end

  test "should get destroy" do
    get menu_item_ingredients_destroy_url
    assert_response :success
  end
end
