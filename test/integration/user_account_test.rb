require "test_helper"

class UserAccountTest < ActionDispatch::IntegrationTest
  # — Authentication guard —————————————————————————————————————————————————

  test "redirects unauthenticated users to sign in" do
    get edit_user_registration_url
    assert_redirected_to new_user_session_url
  end

  # — Edit ——————————————————————————————————————————————————————————————————

  test "renders the edit account page for authenticated users" do
    sign_in_as users(:hr_manager)
    get edit_user_registration_url
    assert_response :ok
  end

  # — Update email ——————————————————————————————————————————————————————————

  test "updates email with valid params and current password" do
    sign_in_as users(:hr_manager)

    patch user_registration_url, params: {
      user: {
        email: "new.email@incubyte.co",
        current_password: "Password1!"
      }
    }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
    assert_equal "new.email@incubyte.co", users(:hr_manager).reload.email
  end

  test "re-renders the edit form with 422 when email is blank" do
    sign_in_as users(:hr_manager)

    patch user_registration_url, params: {
      user: {
        email: "",
        current_password: "Password1!"
      }
    }

    assert_response :unprocessable_content
  end

  test "re-renders the edit form with 422 when current password is wrong" do
    sign_in_as users(:hr_manager)

    patch user_registration_url, params: {
      user: {
        email: "new.email@incubyte.co",
        current_password: "WrongPassword1!"
      }
    }

    assert_response :unprocessable_content
  end

  # — Update password ———————————————————————————————————————————————————————

  test "updates password with valid params and current password" do
    sign_in_as users(:hr_manager)

    patch user_registration_url, params: {
      user: {
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!",
        current_password: "Password1!"
      }
    }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "re-renders the edit form with 422 when password confirmation does not match" do
    sign_in_as users(:hr_manager)

    patch user_registration_url, params: {
      user: {
        password: "NewPassword1!",
        password_confirmation: "DifferentPassword1!",
        current_password: "Password1!"
      }
    }

    assert_response :unprocessable_content
  end
end
