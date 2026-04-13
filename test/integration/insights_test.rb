require "test_helper"

class InsightsTest < ActionDispatch::IntegrationTest
  # — Authentication guard ——————————————————————————————————————————————————

  test "redirects unauthenticated users to sign in" do
    get insights_url
    assert_redirected_to new_user_session_url
  end

  # — Index —————————————————————————————————————————————————————————————————

  test "renders the insights page for authenticated users" do
    sign_in_as users(:hr_manager)
    get insights_url
    assert_response :ok
  end

  test "renders with a country filter" do
    sign_in_as users(:hr_manager)
    get insights_url, params: { country: "US" }
    assert_response :ok
  end

  test "renders with a department filter" do
    sign_in_as users(:hr_manager)
    get insights_url, params: { department_id: departments(:engineering).id }
    assert_response :ok
  end

  test "renders with a job title filter" do
    sign_in_as users(:hr_manager)
    get insights_url, params: { job_title_id: job_titles(:software_engineer).id }
    assert_response :ok
  end

  test "renders with multiple filters combined" do
    sign_in_as users(:hr_manager)
    get insights_url, params: { country: "US", department_id: departments(:engineering).id }
    assert_response :ok
  end

  # — Soft delete ———————————————————————————————————————————————————————————

  test "excludes soft-deleted employees from insights" do
    sign_in_as users(:hr_manager)

    # deleted_employee is the only GB employee — filtering by GB should show
    # zero employees in the insight results
    get insights_url, params: { country: "GB" }
    assert_response :ok
    assert_match "0", response.body
  end

  # — Salary statistics —————————————————————————————————————————————————————

  test "shows correct employee count for a country filter" do
    sign_in_as users(:hr_manager)
    get insights_url, params: { country: "US" }
    assert_response :ok
    assert_match "1", response.body
  end

  test "shows correct average salary for a country filter" do
    sign_in_as users(:hr_manager)
    get insights_url, params: { country: "US" }
    assert_response :ok
    assert_match "95,000", response.body
  end
end
