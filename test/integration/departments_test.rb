require "test_helper"

class DepartmentsTest < ActionDispatch::IntegrationTest
  # — Authentication guard —————————————————————————————————————————————————

  test "redirects unauthenticated users to sign in" do
    get departments_url
    assert_redirected_to new_user_session_url
  end

  # — Index ————————————————————————————————————————————————————————————————

  test "renders the departments list for authenticated users" do
    sign_in_as users(:hr_manager)
    get departments_url
    assert_response :ok
  end

  # — New / Create —————————————————————————————————————————————————————————

  test "renders the new department form" do
    sign_in_as users(:hr_manager)
    get new_department_url
    assert_response :ok
  end

  test "creates a department with valid params and redirects" do
    sign_in_as users(:hr_manager)

    assert_difference "Department.count", 1 do
      post departments_url, params: { department: { name: "Finance" } }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "re-renders the new form with 422 when name is blank" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Department.count" do
      post departments_url, params: { department: { name: "" } }
    end

    assert_response :unprocessable_content
  end

  test "re-renders the new form with 422 on a duplicate name" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Department.count" do
      post departments_url, params: { department: { name: departments(:engineering).name } }
    end

    assert_response :unprocessable_content
  end

  # — Edit / Update ————————————————————————————————————————————————————————

  test "renders the edit department form" do
    sign_in_as users(:hr_manager)
    get edit_department_url(departments(:engineering))
    assert_response :ok
  end

  test "updates a department with valid params and redirects" do
    sign_in_as users(:hr_manager)

    patch department_url(departments(:qa)), params: { department: { name: "Quality Assurance" } }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
    assert_equal "Quality Assurance", departments(:qa).reload.name
  end

  test "re-renders the edit form with 422 when name is blank" do
    sign_in_as users(:hr_manager)

    patch department_url(departments(:engineering)), params: { department: { name: "" } }

    assert_response :unprocessable_content
  end

  # — Delete ———————————————————————————————————————————————————————————————

  test "deletes a department with no assigned employees and redirects" do
    sign_in_as users(:hr_manager)

    assert_difference "Department.count", -1 do
      delete department_url(departments(:qa))
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "prevents deletion of a department that has employees assigned" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Department.count" do
      delete department_url(departments(:engineering))
    end

    assert_response :unprocessable_content
  end
end
