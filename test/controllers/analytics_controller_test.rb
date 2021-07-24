require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get crash" do
    get analytics_crash_url
    assert_response :success
  end

  test "should get version" do
    get analytics_version_url
    assert_response :success
  end
end
