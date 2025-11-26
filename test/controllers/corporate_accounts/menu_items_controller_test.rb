require "test_helper"

class CorporateAccounts::MenuItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get corporate_accounts_menu_items_index_url
    assert_response :success
  end

  test "should get show" do
    get corporate_accounts_menu_items_show_url
    assert_response :success
  end

  test "should get new" do
    get corporate_accounts_menu_items_new_url
    assert_response :success
  end

  test "should get create" do
    get corporate_accounts_menu_items_create_url
    assert_response :success
  end

  test "should get edit" do
    get corporate_accounts_menu_items_edit_url
    assert_response :success
  end

  test "should get update" do
    get corporate_accounts_menu_items_update_url
    assert_response :success
  end

  test "should get bulk_edit" do
    get corporate_accounts_menu_items_bulk_edit_url
    assert_response :success
  end

  test "should get bulk_update" do
    get corporate_accounts_menu_items_bulk_update_url
    assert_response :success
  end
end
