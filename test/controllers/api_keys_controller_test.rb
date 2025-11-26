require "test_helper"

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_keys_index_url
    assert_response :success
  end

  test "should get create" do
    get api_keys_create_url
    assert_response :success
  end

  test "should get destroy" do
    get api_keys_destroy_url
    assert_response :success
  end

  test "should get regenerate" do
    get api_keys_regenerate_url
    assert_response :success
  end
end
