require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  # — Validity ——————————————————————————————————————————————————————————————

  test "is valid with valid attributes" do
    employee = Employee.new(
      first_name: "Bob",
      last_name: "Jones",
      email: "bob.jones@company.com",
      job_title: job_titles(:senior_software_engineer),
      department: "Engineering",
      country: "US",
      salary: 110000.00,
      currency: "USD",
      employment_type: "full_time",
      hired_on: Date.today
    )
    assert employee.valid?
  end

  # — Presence validations ——————————————————————————————————————————————————

  test "is invalid without a first name" do
    employee = employees(:john_doe).tap { |e| e.first_name = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:first_name], "can't be blank"
  end

  test "is invalid without a last name" do
    employee = employees(:john_doe).tap { |e| e.last_name = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:last_name], "can't be blank"
  end

  test "is invalid without an email" do
    employee = employees(:john_doe).tap { |e| e.email = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:email], "can't be blank"
  end

  test "is invalid without a department" do
    employee = employees(:john_doe).tap { |e| e.department = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:department], "can't be blank"
  end

  test "is invalid without a country" do
    employee = employees(:john_doe).tap { |e| e.country = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:country], "can't be blank"
  end

  test "is invalid without a salary" do
    employee = employees(:john_doe).tap { |e| e.salary = nil }
    assert_not employee.valid?
    assert_includes employee.errors[:salary], "can't be blank"
  end

  test "is invalid with a salary of zero" do
    employee = employees(:john_doe).tap { |e| e.salary = 0 }
    assert_not employee.valid?
    assert_includes employee.errors[:salary], "must be greater than 0"
  end

  test "is invalid without a currency" do
    employee = employees(:john_doe).tap { |e| e.currency = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:currency], "can't be blank"
  end

  test "is invalid without an employment type" do
    employee = employees(:john_doe).tap { |e| e.employment_type = "" }
    assert_not employee.valid?
    assert_includes employee.errors[:employment_type], "can't be blank"
  end

  test "is invalid without a hire date" do
    employee = employees(:john_doe).tap { |e| e.hired_on = nil }
    assert_not employee.valid?
    assert_includes employee.errors[:hired_on], "can't be blank"
  end

  # — Email validations ——————————————————————————————————————————————————————

  test "is invalid with a duplicate email" do
    employee = Employee.new(email: employees(:john_doe).email)
    assert_not employee.valid?
    assert_includes employee.errors[:email], "has already been taken"
  end

  # — Employment type validations ———————————————————————————————————————————

  test "is valid with employment type full_time" do
    employee = employees(:john_doe).tap { |e| e.employment_type = "full_time" }
    assert employee.valid?
  end

  test "is valid with employment type part_time" do
    employee = employees(:john_doe).tap { |e| e.employment_type = "part_time" }
    assert employee.valid?
  end

  test "is valid with employment type contract" do
    employee = employees(:john_doe).tap { |e| e.employment_type = "contract" }
    assert employee.valid?
  end

  test "is invalid with an unrecognised employment type" do
    employee = employees(:john_doe).tap { |e| e.employment_type = "freelance" }
    assert_not employee.valid?
    assert_includes employee.errors[:employment_type], "is not included in the list"
  end

  # — Instance methods ——————————————————————————————————————————————————————

  test "full_name returns first and last name" do
    assert_equal "John Doe", employees(:john_doe).full_name
  end

  # — Associations ——————————————————————————————————————————————————————————

  test "belongs to a job title" do
    assert_equal job_titles(:software_engineer), employees(:john_doe).job_title
  end

  test "has many salary histories" do
    assert_respond_to employees(:john_doe), :salary_histories
  end

  # — Soft delete ———————————————————————————————————————————————————————————

  test "excludes soft-deleted employees from default queries" do
    assert_not Employee.exists?(employees(:deleted_employee).id)
  end

  test "soft-deleted employees are findable with unscoped" do
    assert Employee.unscoped.exists?(employees(:deleted_employee).id)
  end

  # — Salary history callback ———————————————————————————————————————————————

  test "records a salary history entry when salary is updated" do
    employee = employees(:john_doe)

    assert_difference "SalaryHistory.where(employee: employee).count", 1 do
      employee.update!(salary: 105000.00, currency: "USD")
    end

    history = SalaryHistory.where(employee: employee).last
    assert_equal 105000.00, history.salary.to_f
    assert_equal "USD", history.currency
    assert_equal Date.today, history.effective_from
  end

  test "does not record salary history when non-salary fields are updated" do
    employee = employees(:john_doe)

    assert_no_difference "SalaryHistory.where(employee: employee).count" do
      employee.update!(department: "Platform Engineering")
    end
  end
end
