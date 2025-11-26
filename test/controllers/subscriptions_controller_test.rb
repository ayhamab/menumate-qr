require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get subscriptions_show_url
    assert_response :success
  end

  test "should get create" do
    get subscriptions_create_url
    assert_response :success
  end

  test "should get update" do
    get subscriptions_update_url
    assert_response :success
  end

  test "should get destroy" do
    get subscriptions_destroy_url
    assert_response :success
  end

  test "should get checkout" do
    get subscriptions_checkout_url
    assert_response :success
  end

  test "should get cancel" do
    get subscriptions_cancel_url
    assert_response :success
  end

  test "should get reactivate" do
    get subscriptions_reactivate_url
    assert_response :success
  end

  test "should get success" do
    get subscriptions_success_url
    assert_response :success
  end

  test "should get canceled" do
    get subscriptions_canceled_url
    assert_response :success
  end
end
