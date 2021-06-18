require "test_helper"

class CredentialsControllerTest < ActionDispatch::IntegrationTest
  test "should get set" do
    get credentials_set_url
    assert_response :success
  end
end
