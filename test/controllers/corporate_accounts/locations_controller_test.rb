require "test_helper"

class CorporateAccounts::LocationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get corporate_accounts_locations_index_url
    assert_response :success
  end

  test "should get show" do
    get corporate_accounts_locations_show_url
    assert_response :success
  end

  test "should get new" do
    get corporate_accounts_locations_new_url
    assert_response :success
  end

  test "should get create" do
    get corporate_accounts_locations_create_url
    assert_response :success
  end

  test "should get edit" do
    get corporate_accounts_locations_edit_url
    assert_response :success
  end

  test "should get update" do
    get corporate_accounts_locations_update_url
    assert_response :success
  end
end
