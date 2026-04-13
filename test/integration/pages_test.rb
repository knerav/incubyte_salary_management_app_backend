require "test_helper"

class PagesTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users to sign in" do
    get root_url
    assert_redirected_to new_user_session_url
  end

  test "renders the homepage for authenticated users" do
    sign_in_as users(:hr_manager)
    get root_url
    assert_response :ok
  end
end
