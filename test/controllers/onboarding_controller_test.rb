require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get onboarding_index_url
    assert_response :success
  end

  test "should get step" do
    get onboarding_step_url
    assert_response :success
  end

  test "should get complete" do
    get onboarding_complete_url
    assert_response :success
  end
end
