require "test_helper"

class EmployeesTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users to sign in" do
    get employees_url
    assert_redirected_to new_user_session_url
  end

  test "renders the employees page for authenticated users" do
    sign_in_as users(:hr_manager)
    get employees_url
    assert_response :ok
  end
end
