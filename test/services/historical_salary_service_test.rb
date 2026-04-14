require "test_helper"

class HistoricalSalaryServiceTest < ActiveSupport::TestCase
  # — Default date range ————————————————————————————————————————————————————

  test "returns a series array" do
    result = HistoricalSalaryService.new({}).call
    assert_respond_to result, :series
  end

  test "returns an empty series when no salary histories fall within the date range" do
    result = HistoricalSalaryService.new({}, from: Date.today + 1.year, to: Date.today + 2.years).call
    assert_empty result.series
  end

  # — Group by month ————————————————————————————————————————————————————————

  test "groups results by month by default" do
    result = HistoricalSalaryService.new({}, from: "2023-01-01", to: "2023-01-31").call
    assert_equal 1, result.series.length
    assert_equal "2023-01", result.series.first[:period]
  end

  test "each month entry includes avg_salary and employee_count" do
    result = HistoricalSalaryService.new({}, from: "2023-01-01", to: "2023-01-31").call
    entry = result.series.first
    assert entry.key?(:period)
    assert entry.key?(:avg_salary)
    assert entry.key?(:employee_count)
  end

  test "calculates correct avg_salary for a month" do
    result = HistoricalSalaryService.new({}, from: "2023-01-01", to: "2023-01-31").call
    assert_in_delta 95000.00, result.series.first[:avg_salary].to_f, 0.01
  end

  # — Group by quarter ——————————————————————————————————————————————————————

  test "groups results by quarter" do
    result = HistoricalSalaryService.new({}, from: "2023-01-01", to: "2023-03-31", group_by: "quarter").call
    assert_equal 1, result.series.length
    assert_equal "2023-Q1", result.series.first[:period]
  end

  # — Group by year —————————————————————————————————————————————————————————

  test "groups results by year" do
    result = HistoricalSalaryService.new({}, from: "2022-01-01", to: "2023-12-31", group_by: "year").call
    periods = result.series.map { |e| e[:period] }
    assert_includes periods, "2022"
    assert_includes periods, "2023"
  end

  # — Employee scope filters ————————————————————————————————————————————————

  test "scopes history to a filtered set of employees" do
    filters = { country: "US" }
    result = HistoricalSalaryService.new(filters, from: "2022-01-01", to: "2023-12-31", group_by: "year").call
    periods = result.series.map { |e| e[:period] }
    assert_includes periods, "2022"
    assert_includes periods, "2023"
  end

  test "returns empty series when employee filter matches no one" do
    result = HistoricalSalaryService.new({ country: "AU" }, from: "2020-01-01", to: "2024-12-31").call
    assert_empty result.series
  end

  # — Series ordering ———————————————————————————————————————————————————————

  test "series entries are ordered chronologically" do
    result = HistoricalSalaryService.new({}, from: "2021-01-01", to: "2023-12-31", group_by: "year").call
    periods = result.series.map { |e| e[:period] }
    assert_equal periods.sort, periods
  end
end
