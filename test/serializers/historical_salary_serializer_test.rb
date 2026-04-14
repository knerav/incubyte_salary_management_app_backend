require "test_helper"

class HistoricalSalarySerializerTest < ActiveSupport::TestCase
  setup do
    result  = HistoricalSalaryService.new({}, from: "2022-01-01", to: "2023-12-31", group_by: "year").call
    @filters = {}
    @result  = HistoricalSalarySerializer.new(result, @filters, group_by: "year").as_json
  end

  # — Top-level keys ————————————————————————————————————————————————————————

  test "includes a filters key" do
    assert @result.key?(:filters)
  end

  test "includes a group_by key" do
    assert @result.key?(:group_by)
  end

  test "includes a series key" do
    assert @result.key?(:series)
  end

  # — Group by ——————————————————————————————————————————————————————————————

  test "reflects the group_by parameter" do
    assert_equal "year", @result[:group_by]
  end

  # — Series ————————————————————————————————————————————————————————————————

  test "series is an array" do
    assert_instance_of Array, @result[:series]
  end

  test "each series entry includes period" do
    @result[:series].each { |entry| assert entry.key?(:period) }
  end

  test "each series entry includes avg_salary as a string" do
    @result[:series].each do |entry|
      assert entry.key?(:avg_salary)
      assert_instance_of String, entry[:avg_salary]
    end
  end

  test "each series entry includes employee_count" do
    @result[:series].each { |entry| assert entry.key?(:employee_count) }
  end
end
