namespace :employees do
  desc "Backfill initial salary history entries for employees seeded via upsert_all (idempotent)"
  task backfill_salary_histories: :environment do
    employees = Employee.where.missing(:salary_histories)

    count = 0

    employees.find_each do |employee|
      SalaryHistory.create!(
        employee:       employee,
        salary:         employee.salary,
        currency:       employee.currency,
        effective_from: employee.hired_on
      )
      count += 1
    end

    puts "✓ Backfilled salary history for #{count} employee(s)"
  end
end
