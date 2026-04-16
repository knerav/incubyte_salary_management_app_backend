require "test_helper"

class EmployeesTest < ActionDispatch::IntegrationTest
  # — Authentication guard ——————————————————————————————————————————————————

  test "redirects unauthenticated users to sign in" do
    get employees_url
    assert_redirected_to new_user_session_url
  end

  # — Index —————————————————————————————————————————————————————————————————

  test "renders the employee list for authenticated users" do
    sign_in_as users(:hr_manager)
    get employees_url
    assert_response :ok
  end

  # — Show ——————————————————————————————————————————————————————————————————

  test "renders the employee profile" do
    sign_in_as users(:hr_manager)
    get employee_url(employees(:john_doe))
    assert_response :ok
  end

  test "returns 404 for a soft-deleted employee" do
    sign_in_as users(:hr_manager)
    get employee_url(employees(:deleted_employee))
    assert_response :not_found
  end

  # — New / Create ——————————————————————————————————————————————————————————

  test "renders the new employee form" do
    sign_in_as users(:hr_manager)
    get new_employee_url
    assert_response :ok
  end

  test "creates an employee with valid params and redirects" do
    sign_in_as users(:hr_manager)

    assert_difference "Employee.count", 1 do
      post employees_url, params: {
        employee: {
          first_name: "Bob",
          last_name: "Jones",
          email: "bob.jones@company.com",
          job_title_id: job_titles(:senior_software_engineer).id,
          department_id: departments(:engineering).id,
          country: "US",
          salary: "110000.00",
          currency: "USD",
          employment_type: "full_time",
          hired_on: "2024-01-15"
        }
      }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "creates an employee via turbo stream and returns stream response" do
    sign_in_as users(:hr_manager)

    assert_difference "Employee.count", 1 do
      post employees_url,
        params: {
          employee: {
            first_name: "Bob",
            last_name: "Jones",
            email: "bob.jones@company.com",
            job_title_id: job_titles(:senior_software_engineer).id,
            department_id: departments(:engineering).id,
            country: "US",
            salary: "110000.00",
            currency: "USD",
            employment_type: "full_time",
            hired_on: "2024-01-15"
          }
        },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "re-renders the new form with 422 when required fields are blank" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Employee.count" do
      post employees_url, params: {
        employee: { first_name: "", last_name: "", email: "" }
      }
    end

    assert_response :unprocessable_content
  end

  test "re-renders modal via turbo stream with 422 when required fields are blank" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Employee.count" do
      post employees_url,
        params: { employee: { first_name: "", last_name: "", email: "" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :unprocessable_content
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "re-renders the new form with 422 on a duplicate email" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Employee.count" do
      post employees_url, params: {
        employee: {
          first_name: "Duplicate",
          last_name: "User",
          email: employees(:john_doe).email,
          job_title_id: job_titles(:software_engineer).id,
          department_id: departments(:engineering).id,
          country: "US",
          salary: "80000.00",
          currency: "USD",
          employment_type: "full_time",
          hired_on: "2024-01-15"
        }
      }
    end

    assert_response :unprocessable_content
  end

  # — Edit / Update —————————————————————————————————————————————————————————

  test "renders the edit employee form" do
    sign_in_as users(:hr_manager)
    get edit_employee_url(employees(:john_doe))
    assert_response :ok
  end

  test "updates an employee with valid params and redirects" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)), params: {
      employee: { department_id: departments(:product).id }
    }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
    assert_equal departments(:product), employees(:john_doe).reload.department
  end

  test "re-renders the edit form with 422 when required fields are blank" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)), params: {
      employee: { first_name: "" }
    }

    assert_response :unprocessable_content
  end

  # — Salary update —————————————————————————————————————————————————————————

  test "updates salary and records a salary history entry" do
    sign_in_as users(:hr_manager)

    assert_difference "SalaryHistory.count", 1 do
      patch salary_employee_url(employees(:john_doe)), params: {
        employee: { salary: "105000.00", currency: "USD" }
      }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
    assert_equal 105000.00, employees(:john_doe).reload.salary.to_f
  end

  test "re-renders with 422 on an invalid salary and does not record history" do
    sign_in_as users(:hr_manager)

    assert_no_difference "SalaryHistory.count" do
      patch salary_employee_url(employees(:john_doe)), params: {
        employee: { salary: "0", currency: "USD" }
      }
    end

    assert_response :unprocessable_content
  end

  # — Destroy ———————————————————————————————————————————————————————————————

  test "soft deletes an employee and redirects" do
    sign_in_as users(:hr_manager)

    assert_no_difference "Employee.unscoped.count" do
      delete employee_url(employees(:john_doe))
    end

    assert_not_nil employees(:john_doe).reload.deleted_at
    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "returns 404 after an employee is soft deleted" do
    sign_in_as users(:hr_manager)
    delete employee_url(employees(:john_doe))

    get employee_url(employees(:john_doe))
    assert_response :not_found
  end
end
