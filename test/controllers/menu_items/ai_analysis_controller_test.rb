require "test_helper"

class MenuItems::AiAnalysisControllerTest < ActionDispatch::IntegrationTest
  test "should get analyze" do
    get menu_items_ai_analysis_analyze_url
    assert_response :success
  end

  test "should get suggest_improvements" do
    get menu_items_ai_analysis_suggest_improvements_url
    assert_response :success
  end
end
