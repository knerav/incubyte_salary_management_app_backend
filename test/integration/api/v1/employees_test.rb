require "test_helper"

module Api
  module V1
    class EmployeesTest < ActionDispatch::IntegrationTest
  # — Authentication guard —————————————————————————————————————————————————

  test "returns 401 without a JWT token" do
    get api_v1_employees_url, as: :json
    assert_response :unauthorized
  end

  # — Index ————————————————————————————————————————————————————————————————

  test "returns a list of employees" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employees_url, headers: { Authorization: token }, as: :json
    assert_response :ok
    assert_includes response.parsed_body.keys, "employees"
  end

  test "response includes pagination meta" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employees_url, headers: { Authorization: token }, as: :json
    assert_includes response.parsed_body.keys, "meta"
    meta = response.parsed_body["meta"]
    assert meta.key?("total")
    assert meta.key?("page")
    assert meta.key?("per_page")
    assert meta.key?("total_pages")
  end

  test "excludes soft-deleted employees from the list" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employees_url, headers: { Authorization: token }, as: :json
    ids = response.parsed_body["employees"].map { |e| e["id"] }
    assert_not_includes ids, employees(:deleted_employee).id
  end

  test "filters employees by country" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employees_url, params: { country: "US" }, headers: { Authorization: token }, as: :json
    ids = response.parsed_body["employees"].map { |e| e["id"] }
    assert_includes ids, employees(:john_doe).id
    assert_not_includes ids, employees(:jane_smith).id
  end

  # — Show ——————————————————————————————————————————————————————————————————

  test "returns an employee" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employee_url(employees(:john_doe)), headers: { Authorization: token }, as: :json
    assert_response :ok
    assert_equal employees(:john_doe).id, response.parsed_body["id"]
  end

  test "returns 404 for a soft-deleted employee" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employee_url(employees(:deleted_employee)), headers: { Authorization: token }, as: :json
    assert_response :not_found
  end

  test "employee response includes the expected fields" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employee_url(employees(:john_doe)), headers: { Authorization: token }, as: :json
    body = response.parsed_body
    %w[id first_name last_name email job_title department country salary currency employment_type hired_on].each do |field|
      assert body.key?(field), "expected response to include #{field}"
    end
  end

  test "employee response does not expose sensitive fields" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_employee_url(employees(:john_doe)), headers: { Authorization: token }, as: :json
    body = response.parsed_body
    assert_not body.key?("deleted_at")
    assert_not body.key?("job_title_id")
    assert_not body.key?("department_id")
  end

  # — Create ————————————————————————————————————————————————————————————————

  test "creates an employee with valid params" do
    token = api_sign_in(users(:hr_manager))

    assert_difference "Employee.count", 1 do
      post api_v1_employees_url,
        params: {
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
        },
        headers: { Authorization: token },
        as: :json
    end

    assert_response :created
  end

  test "returns 422 with validation errors on invalid create" do
    token = api_sign_in(users(:hr_manager))

    assert_no_difference "Employee.count" do
      post api_v1_employees_url,
        params: { first_name: "", last_name: "", email: "" },
        headers: { Authorization: token },
        as: :json
    end

    assert_response :unprocessable_content
    assert response.parsed_body.key?("errors")
  end

  # — Update ————————————————————————————————————————————————————————————————

  test "updates an employee with valid params" do
    token = api_sign_in(users(:hr_manager))

    patch api_v1_employee_url(employees(:john_doe)),
      params: { country: "CA" },
      headers: { Authorization: token },
      as: :json

    assert_response :ok
    assert_equal "CA", employees(:john_doe).reload.country
  end

  test "returns 422 on invalid update" do
    token = api_sign_in(users(:hr_manager))

    patch api_v1_employee_url(employees(:john_doe)),
      params: { first_name: "" },
      headers: { Authorization: token },
      as: :json

    assert_response :unprocessable_content
  end

  # — Salary update —————————————————————————————————————————————————————————

  test "updates salary and records a salary history entry" do
    token = api_sign_in(users(:hr_manager))

    assert_difference "SalaryHistory.count", 1 do
      patch salary_api_v1_employee_url(employees(:john_doe)),
        params: { salary: "105000.00", currency: "USD" },
        headers: { Authorization: token },
        as: :json
    end

    assert_response :ok
    assert_equal 105000.00, employees(:john_doe).reload.salary.to_f
  end

  test "returns 422 on invalid salary update" do
    token = api_sign_in(users(:hr_manager))

    assert_no_difference "SalaryHistory.count" do
      patch salary_api_v1_employee_url(employees(:john_doe)),
        params: { salary: "0", currency: "USD" },
        headers: { Authorization: token },
        as: :json
    end

    assert_response :unprocessable_content
  end

  # — Destroy ———————————————————————————————————————————————————————————————

  test "soft deletes an employee" do
    token = api_sign_in(users(:hr_manager))

    assert_no_difference "Employee.unscoped.count" do
      delete api_v1_employee_url(employees(:john_doe)), headers: { Authorization: token }, as: :json
    end

    assert_response :no_content
    assert_not_nil employees(:john_doe).reload.deleted_at
  end

  test "returns 404 when deleting a soft-deleted employee" do
    token = api_sign_in(users(:hr_manager))
    delete api_v1_employee_url(employees(:deleted_employee)), headers: { Authorization: token }, as: :json
    assert_response :not_found
  end

  # — Salary history ————————————————————————————————————————————————————————

  test "returns 401 on salary history without a JWT token" do
    get salary_history_api_v1_employee_url(employees(:john_doe)), as: :json
    assert_response :unauthorized
  end

  test "returns salary history for an employee" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:john_doe)),
      headers: { Authorization: token }, as: :json
    assert_response :ok
  end

  test "salary history response includes a salary_history array" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:john_doe)),
      headers: { Authorization: token }, as: :json
    assert response.parsed_body.key?("salary_history")
    assert_instance_of Array, response.parsed_body["salary_history"]
  end

  test "each salary history entry includes effective_from, salary, currency, and change" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:john_doe)),
      headers: { Authorization: token }, as: :json
    entry = response.parsed_body["salary_history"].first
    %w[effective_from salary currency change].each do |field|
      assert entry.key?(field), "expected entry to include #{field}"
    end
  end

  test "salary history entries are ordered chronologically" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:john_doe)),
      headers: { Authorization: token }, as: :json
    dates = response.parsed_body["salary_history"].map { |e| e["effective_from"] }
    assert_equal dates.sort, dates
  end

  test "first salary history entry has a null change" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:john_doe)),
      headers: { Authorization: token }, as: :json
    assert_nil response.parsed_body["salary_history"].first["change"]
  end

  test "subsequent salary history entries include a change percentage" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:john_doe)),
      headers: { Authorization: token }, as: :json
    change = response.parsed_body["salary_history"].last["change"]
    assert_not_nil change
    assert_match(/\A[+-]\d+\.\d+%\z/, change)
  end

  test "returns 404 for salary history of a soft-deleted employee" do
    token = api_sign_in(users(:hr_manager))
    get salary_history_api_v1_employee_url(employees(:deleted_employee)),
      headers: { Authorization: token }, as: :json
    assert_response :not_found
  end
    end
  end
end
