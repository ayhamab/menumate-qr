require "test_helper"

class ApiDocumentationControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_documentation_index_url
    assert_response :success
  end
end
