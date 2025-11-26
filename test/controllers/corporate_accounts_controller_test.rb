require "test_helper"

class CorporateAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get corporate_accounts_index_url
    assert_response :success
  end

  test "should get show" do
    get corporate_accounts_show_url
    assert_response :success
  end

  test "should get new" do
    get corporate_accounts_new_url
    assert_response :success
  end

  test "should get create" do
    get corporate_accounts_create_url
    assert_response :success
  end

  test "should get edit" do
    get corporate_accounts_edit_url
    assert_response :success
  end

  test "should get update" do
    get corporate_accounts_update_url
    assert_response :success
  end

  test "should get dashboard" do
    get corporate_accounts_dashboard_url
    assert_response :success
  end
end
