require "test_helper"

class UserSessionsTest < ActionDispatch::IntegrationTest
  # — Sign in form —————————————————————————————————————————————————————————

  test "renders the sign in form" do
    get new_user_session_url
    assert_response :ok
  end

  # — Sign in ——————————————————————————————————————————————————————————————

  test "signs in with valid credentials and redirects" do
    post user_session_url,
      params: { user: { email: users(:hr_manager).email, password: "Password1!" } }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "re-renders the sign in form with 422 on invalid password" do
    post user_session_url,
      params: { user: { email: users(:hr_manager).email, password: "wrongpassword" } }

    assert_response :unprocessable_content
  end

  test "re-renders the sign in form with 422 for an unregistered email" do
    post user_session_url,
      params: { user: { email: "nobody@example.com", password: "Password1!" } }

    assert_response :unprocessable_content
  end

  # — Sign out —————————————————————————————————————————————————————————————

  test "signs out and redirects" do
    sign_in_as users(:hr_manager)

    delete destroy_user_session_url

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end
end
