require "test_helper"

class UserRegistrationsTest < ActionDispatch::IntegrationTest
  # — Sign up form —————————————————————————————————————————————————————————

  test "renders the sign up form" do
    get new_user_registration_url
    assert_response :ok
  end

  # — Sign up ——————————————————————————————————————————————————————————————

  test "creates a new user with valid params and redirects" do
    assert_difference "User.count", 1 do
      post user_registration_url,
        params: { user: { email: "new@incubyte.co", password: "Password1!", password_confirmation: "Password1!" } }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "re-renders the sign up form with 422 when email is missing" do
    assert_no_difference "User.count" do
      post user_registration_url,
        params: { user: { password: "Password1!", password_confirmation: "Password1!" } }
    end

    assert_response :unprocessable_content
  end

  test "re-renders the sign up form with 422 on duplicate email" do
    assert_no_difference "User.count" do
      post user_registration_url,
        params: { user: { email: users(:hr_manager).email, password: "Password1!", password_confirmation: "Password1!" } }
    end

    assert_response :unprocessable_content
  end

  test "re-renders the sign up form with 422 when password confirmation does not match" do
    assert_no_difference "User.count" do
      post user_registration_url,
        params: { user: { email: "new@incubyte.co", password: "Password1!", password_confirmation: "Different1!" } }
    end

    assert_response :unprocessable_content
  end

  test "re-renders the sign up form with 422 when password is too short" do
    assert_no_difference "User.count" do
      post user_registration_url,
        params: { user: { email: "new@incubyte.co", password: "short", password_confirmation: "short" } }
    end

    assert_response :unprocessable_content
  end
end
