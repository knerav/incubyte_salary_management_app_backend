require "test_helper"

class SalaryHistoryTest < ActiveSupport::TestCase
  # — Validity ——————————————————————————————————————————————————————————————

  test "is valid with valid attributes" do
    history = SalaryHistory.new(
      employee: employees(:john_doe),
      salary: 100000.00,
      currency: "USD",
      effective_from: Date.today
    )
    assert history.valid?
  end

  # — Presence validations ——————————————————————————————————————————————————

  test "is invalid without a salary" do
    history = SalaryHistory.new(salary: nil)
    assert_not history.valid?
    assert_includes history.errors[:salary], "can't be blank"
  end

  test "is invalid with a salary of zero" do
    history = SalaryHistory.new(salary: 0)
    assert_not history.valid?
    assert_includes history.errors[:salary], "must be greater than 0"
  end

  test "is invalid without a currency" do
    history = SalaryHistory.new(currency: "")
    assert_not history.valid?
    assert_includes history.errors[:currency], "can't be blank"
  end

  test "is invalid without an effective_from date" do
    history = SalaryHistory.new(effective_from: nil)
    assert_not history.valid?
    assert_includes history.errors[:effective_from], "can't be blank"
  end

  # — Association ———————————————————————————————————————————————————————————

  test "belongs to an employee" do
    assert_equal employees(:john_doe), salary_histories(:john_doe_raise).employee
  end

  # — Immutability ——————————————————————————————————————————————————————————

  test "cannot be updated once created" do
    history = salary_histories(:john_doe_raise)
    original_salary = history.salary

    history.update(salary: 999999.00)

    assert_equal original_salary, history.reload.salary
  end

  # — Ordering ——————————————————————————————————————————————————————————————

  test "records are ordered chronologically by effective_from" do
    histories = SalaryHistory.where(employee: employees(:john_doe))
                             .order(:effective_from)
    assert_equal salary_histories(:john_doe_initial).effective_from,
                 histories.first.effective_from
    assert_equal salary_histories(:john_doe_raise).effective_from,
                 histories.last.effective_from
  end

end
