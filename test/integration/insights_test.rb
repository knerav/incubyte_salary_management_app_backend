require "test_helper"

class InsightsTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users to sign in" do
    get insights_url
    assert_redirected_to new_user_session_url
  end

  test "renders the insights page for authenticated users" do
    sign_in_as users(:hr_manager)
    get insights_url
    assert_response :ok
  end
end
