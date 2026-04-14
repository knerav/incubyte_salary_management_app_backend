require "test_helper"

class EmployeeFilterServiceTest < ActiveSupport::TestCase
  # — No filters ————————————————————————————————————————————————————————————

  test "returns all active employees when no filters are given" do
    result = EmployeeFilterService.new({}).call
    assert_includes result, employees(:john_doe)
    assert_includes result, employees(:jane_smith)
  end

  test "excludes soft-deleted employees regardless of filters" do
    result = EmployeeFilterService.new({}).call
    assert_not_includes result, employees(:deleted_employee)
  end

  # — Country filter ————————————————————————————————————————————————————————

  test "filters by country" do
    result = EmployeeFilterService.new(country: "US").call
    assert_includes result, employees(:john_doe)
    assert_not_includes result, employees(:jane_smith)
  end

  # — Department filter —————————————————————————————————————————————————————

  test "filters by department_id" do
    result = EmployeeFilterService.new(department_id: departments(:engineering).id).call
    assert_includes result, employees(:john_doe)
    assert_not_includes result, employees(:jane_smith)
  end

  # — Job title filter ——————————————————————————————————————————————————————

  test "filters by job_title_id" do
    result = EmployeeFilterService.new(job_title_id: job_titles(:software_engineer).id).call
    assert_includes result, employees(:john_doe)
    assert_not_includes result, employees(:jane_smith)
  end

  # — Employment type filter ————————————————————————————————————————————————

  test "filters by employment_type" do
    result = EmployeeFilterService.new(employment_type: "full_time").call
    assert_includes result, employees(:john_doe)
    assert_includes result, employees(:jane_smith)
    assert_not_includes result, employees(:deleted_employee)
  end

  # — Name search ———————————————————————————————————————————————————————————

  test "filters by name search query" do
    result = EmployeeFilterService.new(q: "john").call
    assert_includes result, employees(:john_doe)
    assert_not_includes result, employees(:jane_smith)
  end

  test "name search is case-insensitive" do
    result = EmployeeFilterService.new(q: "JOHN").call
    assert_includes result, employees(:john_doe)
  end

  test "name search matches on last name" do
    result = EmployeeFilterService.new(q: "smith").call
    assert_includes result, employees(:jane_smith)
    assert_not_includes result, employees(:john_doe)
  end

  # — Additive filters ——————————————————————————————————————————————————————

  test "applies multiple filters additively" do
    result = EmployeeFilterService.new(
      country: "US",
      department_id: departments(:engineering).id
    ).call
    assert_includes result, employees(:john_doe)
    assert_not_includes result, employees(:jane_smith)
  end

  test "returns an empty scope when filters match no employees" do
    result = EmployeeFilterService.new(country: "AU").call
    assert_empty result
  end
end
