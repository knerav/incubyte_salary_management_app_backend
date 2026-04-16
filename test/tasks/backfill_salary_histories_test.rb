require "test_helper"
require "rake"

class BackfillSalaryHistoriesTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["employees:backfill_salary_histories"].reenable
  end

  test "creates an initial salary history entry for employees who have none" do
    employee = Employee.create!(
      first_name: "Bob", last_name: "Builder",
      email: "bob.builder@company.com",
      job_title: job_titles(:software_engineer),
      department: departments(:engineering),
      country: "US", salary: 60_000, currency: "USD",
      employment_type: "full_time", hired_on: "2023-05-01"
    )
    employee.salary_histories.delete_all

    assert_difference "SalaryHistory.count", 1 do
      Rake::Task["employees:backfill_salary_histories"].invoke
    end

    history = employee.salary_histories.sole
    assert_equal employee.salary, history.salary
    assert_equal employee.currency, history.currency
    assert_equal employee.hired_on, history.effective_from
  end

  test "skips employees who already have salary history" do
    assert employees(:john_doe).salary_histories.any?

    assert_no_difference "SalaryHistory.count" do
      Rake::Task["employees:backfill_salary_histories"].invoke
    end
  end

  test "skips soft-deleted employees" do
    deleted = employees(:deleted_employee)
    assert_nil deleted.salary_histories.first

    assert_no_difference "SalaryHistory.count" do
      Rake::Task["employees:backfill_salary_histories"].invoke
    end
  end

  test "is idempotent when run multiple times" do
    employee = Employee.create!(
      first_name: "Carol", last_name: "Kane",
      email: "carol.kane@company.com",
      job_title: job_titles(:software_engineer),
      department: departments(:engineering),
      country: "GB", salary: 55_000, currency: "GBP",
      employment_type: "full_time", hired_on: "2022-08-15"
    )
    employee.salary_histories.delete_all

    Rake::Task["employees:backfill_salary_histories"].invoke
    Rake::Task["employees:backfill_salary_histories"].reenable

    assert_no_difference "SalaryHistory.count" do
      Rake::Task["employees:backfill_salary_histories"].invoke
    end
  end
end
