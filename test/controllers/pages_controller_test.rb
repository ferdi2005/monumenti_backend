require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get uhm" do
    get pages_uhm_url
    assert_response :success
  end
end
