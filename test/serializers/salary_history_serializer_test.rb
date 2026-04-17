require "test_helper"

class SalaryHistorySerializerTest < ActiveSupport::TestCase
  setup do
    @histories = employees(:john_doe).salary_histories.order(:effective_from)
    @result    = SalaryHistorySerializer.new(@histories).as_json
  end

  # — Top-level shape ——————————————————————————————————————————————————————

  test "includes a salary_history key" do
    assert @result.key?(:salary_history)
  end

  test "salary_history is an array" do
    assert_instance_of Array, @result[:salary_history]
  end

  test "returns one entry per salary history record" do
    assert_equal @histories.count, @result[:salary_history].length
  end

  # — Entry fields —————————————————————————————————————————————————————————

  test "each entry includes effective_from, salary, currency, and change" do
    @result[:salary_history].each do |entry|
      %i[effective_from salary currency change].each do |field|
        assert entry.key?(field), "expected entry to include #{field}"
      end
    end
  end

  test "salary is serialised as a string" do
    @result[:salary_history].each do |entry|
      assert_instance_of String, entry[:salary]
    end
  end

  test "effective_from is an ISO 8601 date string" do
    @result[:salary_history].each do |entry|
      assert_match(/\A\d{4}-\d{2}-\d{2}\z/, entry[:effective_from])
    end
  end

  # — Change calculation ———————————————————————————————————————————————————

  test "first entry has a null change" do
    assert_nil @result[:salary_history].first[:change]
  end

  test "subsequent entries include a signed percentage change" do
    @result[:salary_history].drop(1).each do |entry|
      assert_not_nil entry[:change]
      assert_match(/\A[+-]\d+\.\d+%\z/, entry[:change])
    end
  end

  test "change percentage is calculated correctly" do
    # john_doe: 85000.00 → 95000.00 = +11.76%
    assert_equal "+11.76%", @result[:salary_history].last[:change]
  end
end
