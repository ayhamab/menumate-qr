require "test_helper"

class MenuItems::NutritionControllerTest < ActionDispatch::IntegrationTest
  test "should get calculate" do
    get menu_items_nutrition_calculate_url
    assert_response :success
  end

  test "should get update" do
    get menu_items_nutrition_update_url
    assert_response :success
  end
end
