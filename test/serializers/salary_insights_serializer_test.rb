require "test_helper"

class SalaryInsightsSerializerTest < ActiveSupport::TestCase
  setup do
    scope    = EmployeeFilterService.new(country: "US").call
    insights = SalaryInsightsService.new(scope).call
    @filters = { country: "US" }
    @result  = SalaryInsightsSerializer.new(insights, @filters).as_json
  end

  # — Top-level keys ————————————————————————————————————————————————————————

  test "includes a filters key" do
    assert @result.key?(:filters)
  end

  test "includes an insights key" do
    assert @result.key?(:insights)
  end

  # — Filters ———————————————————————————————————————————————————————————————

  test "reflects the applied filters" do
    assert_equal "US", @result[:filters][:country]
  end

  # — Insights ——————————————————————————————————————————————————————————————

  test "includes employee_count" do
    assert @result[:insights].key?(:employee_count)
  end

  test "includes min_salary as a string" do
    assert_instance_of String, @result[:insights][:min_salary]
  end

  test "includes max_salary as a string" do
    assert_instance_of String, @result[:insights][:max_salary]
  end

  test "includes avg_salary as a string" do
    assert_instance_of String, @result[:insights][:avg_salary]
  end

  test "includes breakdowns" do
    assert @result[:insights].key?(:breakdowns)
  end

  test "breakdowns is an array of hashes with job_title and avg_salary" do
    @result[:insights][:breakdowns].each do |entry|
      assert entry.key?(:job_title)
      assert entry.key?(:avg_salary)
    end
  end

  # — Currency ——————————————————————————————————————————————————————————————

  test "includes currency_code in insights" do
    assert @result[:insights].key?(:currency_code)
  end

  test "includes currency_symbol in insights" do
    assert @result[:insights].key?(:currency_symbol)
  end

  test "currency_code matches the filtered country" do
    assert_equal "USD", @result[:insights][:currency_code]
  end

  test "currency_symbol is a non-empty string" do
    assert_instance_of String, @result[:insights][:currency_symbol]
    assert @result[:insights][:currency_symbol].present?
  end
end
