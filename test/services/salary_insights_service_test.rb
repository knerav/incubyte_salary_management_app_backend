require "test_helper"

class SalaryInsightsServiceTest < ActiveSupport::TestCase
  # — Employee count ————————————————————————————————————————————————————————

  test "returns the correct employee count for a scope" do
    scope = Employee.where(country: "US")
    result = SalaryInsightsService.new(scope).call
    assert_equal 1, result.employee_count
  end

  test "returns zero employee count when scope is empty" do
    scope = Employee.where(country: "AU")
    result = SalaryInsightsService.new(scope).call
    assert_equal 0, result.employee_count
  end

  # — Salary stats ——————————————————————————————————————————————————————————

  test "returns the correct min salary" do
    scope = Employee.all
    result = SalaryInsightsService.new(scope).call
    assert_equal 75000.00, result.min_salary
  end

  test "returns the correct max salary" do
    scope = Employee.all
    result = SalaryInsightsService.new(scope).call
    assert_equal 95000.00, result.max_salary
  end

  test "returns the correct avg salary" do
    scope = Employee.all
    result = SalaryInsightsService.new(scope).call
    assert_in_delta 85000.00, result.avg_salary, 0.01
  end

  test "returns nil stats when scope is empty" do
    scope = Employee.where(country: "AU")
    result = SalaryInsightsService.new(scope).call
    assert_nil result.min_salary
    assert_nil result.max_salary
    assert_nil result.avg_salary
  end

  # — Breakdowns ————————————————————————————————————————————————————————————

  test "returns avg salary broken down by job title" do
    scope = Employee.all
    result = SalaryInsightsService.new(scope).call
    assert_includes result.breakdowns.keys, job_titles(:software_engineer).name
    assert_includes result.breakdowns.keys, job_titles(:product_manager).name
  end

  test "breakdowns are sorted in descending order by avg salary" do
    scope = Employee.all
    result = SalaryInsightsService.new(scope).call
    salaries = result.breakdowns.values
    assert_equal salaries.sort.reverse, salaries
  end

  test "returns an empty breakdowns hash when scope is empty" do
    scope = Employee.where(country: "AU")
    result = SalaryInsightsService.new(scope).call
    assert_empty result.breakdowns
  end
end
