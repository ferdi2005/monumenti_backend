require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get authentication_start_url
    assert_response :success
  end
end
