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

  test "renders a search form on the index page" do
    sign_in_as users(:hr_manager)
    get employees_url
    assert_select "form[action='#{employees_path}']"
    assert_select "input[name='q[full_name_cont]']"
  end

  test "search by first name returns matching employees" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { q: { full_name_cont: "John" } }
    assert_response :ok
    assert_match "John", response.body
    assert_no_match "Jane", response.body
  end

  test "search by last name returns matching employees" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { q: { full_name_cont: "Smith" } }
    assert_response :ok
    assert_match "Smith", response.body
    assert_no_match "Doe", response.body
  end

  test "search with no match returns empty list" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { q: { full_name_cont: "Zzznomatch" } }
    assert_response :ok
    assert_select "#employees_empty_state"
  end

  test "search is case-insensitive" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { q: { full_name_cont: "john" } }
    assert_response :ok
    assert_match "John", response.body
  end

  test "blank search returns all employees" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { q: { full_name_cont: "" } }
    assert_response :ok
    assert_match "John", response.body
    assert_match "Jane", response.body
  end

  test "search by full name returns matching employee" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { q: { full_name_cont: "John Doe" } }
    assert_response :ok
    assert_select "##{dom_id(employees(:john_doe))}"
    assert_select "##{dom_id(employees(:jane_smith))}", false
  end

  test "accepts a page param without error" do
    sign_in_as users(:hr_manager)
    get employees_url, params: { page: 1 }
    assert_response :ok
  end

  test "renders pagination nav on the employees page" do
    sign_in_as users(:hr_manager)
    get employees_url
    assert_select "nav.pagy.series-nav"
  end

  test "pagination nav appears twice (top and bottom)" do
    sign_in_as users(:hr_manager)
    get employees_url
    assert_select "nav.pagy.series-nav", count: 2
  end

  # — Show ——————————————————————————————————————————————————————————————————

  test "renders the employee profile" do
    sign_in_as users(:hr_manager)
    get employee_url(employees(:john_doe))
    assert_response :ok
  end

  test "renders the show modal when requested via turbo frame" do
    sign_in_as users(:hr_manager)
    get employee_url(employees(:john_doe)),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :ok
    assert_select "turbo-frame[id='modal']"
    assert_select "dialog"
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

  test "new employee form renders a country select dropdown" do
    sign_in_as users(:hr_manager)
    get new_employee_url
    assert_select "select[name='employee[country]']"
  end

  test "country dropdown is populated with countries from the gem" do
    sign_in_as users(:hr_manager)
    get new_employee_url
    assert_select "select[name='employee[country]'] option[value='US']"
    assert_select "select[name='employee[country]'] option[value='GB']"
    assert_select "select[name='employee[country]'] option[value='IN']"
  end

  test "new employee form renders a currency select dropdown" do
    sign_in_as users(:hr_manager)
    get new_employee_url
    assert_select "select[name='employee[currency]']"
  end

  test "currency dropdown is populated with currency codes from the gem" do
    sign_in_as users(:hr_manager)
    get new_employee_url
    assert_select "select[name='employee[currency]'] option[value='USD']"
    assert_select "select[name='employee[currency]'] option[value='GBP']"
    assert_select "select[name='employee[currency]'] option[value='INR']"
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

  test "turbo stream create response includes a flash notice" do
    sign_in_as users(:hr_manager)

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

    assert_match "Employee was successfully created", response.body
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

  test "renders the edit modal when requested via turbo frame" do
    sign_in_as users(:hr_manager)
    get edit_employee_url(employees(:john_doe)),
        headers: { "Turbo-Frame" => "modal" }
    assert_response :ok
    assert_select "turbo-frame[id='modal']"
    assert_select "dialog"
  end

  test "renders the edit form for a plain HTML request" do
    sign_in_as users(:hr_manager)
    get edit_employee_url(employees(:john_doe))
    assert_response :ok
  end

  test "updates an employee with valid params and returns turbo stream" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)),
          params: { employee: { department_id: departments(:product).id } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_equal departments(:product), employees(:john_doe).reload.department
  end

  test "turbo stream update response includes a flash notice" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)),
          params: { employee: { department_id: departments(:product).id } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_match "Employee was successfully updated", response.body
  end

  test "updates an employee with valid params and redirects for plain HTML" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)), params: {
      employee: { department_id: departments(:product).id }
    }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
    assert_equal departments(:product), employees(:john_doe).reload.department
  end

  test "re-renders the edit modal via turbo stream with 422 when required fields are blank" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)),
          params: { employee: { first_name: "" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :unprocessable_content
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "re-renders the edit form with 422 for plain HTML when required fields are blank" do
    sign_in_as users(:hr_manager)

    patch employee_url(employees(:john_doe)), params: {
      employee: { first_name: "" }
    }

    assert_response :unprocessable_content
  end

  # — Show modal ————————————————————————————————————————————————————————————

  test "show modal salary update form renders a currency select dropdown" do
    sign_in_as users(:hr_manager)
    get employee_url(employees(:john_doe)), headers: { "Turbo-Frame" => "modal" }
    assert_select "select[name='employee[currency]']"
  end

  test "currency dropdown in show modal is populated with currency codes" do
    sign_in_as users(:hr_manager)
    get employee_url(employees(:john_doe)), headers: { "Turbo-Frame" => "modal" }
    assert_select "select[name='employee[currency]'] option[value='USD']"
    assert_select "select[name='employee[currency]'] option[value='EUR']"
    assert_select "select[name='employee[currency]'] option[value='INR']"
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

  test "salary update via turbo stream returns stream response and includes flash notice" do
    sign_in_as users(:hr_manager)

    assert_difference "SalaryHistory.count", 1 do
      patch salary_employee_url(employees(:john_doe)),
            params: { employee: { salary: "105000.00", currency: "USD" } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match "Salary was successfully updated", response.body
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

  test "delete via turbo stream removes the employee row and shows a flash notice" do
    sign_in_as users(:hr_manager)

    delete employee_url(employees(:john_doe)),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match "Employee was successfully deleted", response.body
  end
end
