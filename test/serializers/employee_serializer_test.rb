require "test_helper"

class EmployeeSerializerTest < ActiveSupport::TestCase
  setup do
    @employee = employees(:john_doe)
    @result   = EmployeeSerializer.new(@employee).as_json
  end

  # — Fields present ————————————————————————————————————————————————————————

  test "includes id" do
    assert_equal @employee.id, @result[:id]
  end

  test "includes first_name" do
    assert_equal @employee.first_name, @result[:first_name]
  end

  test "includes last_name" do
    assert_equal @employee.last_name, @result[:last_name]
  end

  test "includes email" do
    assert_equal @employee.email, @result[:email]
  end

  test "resolves job_title name" do
    assert_equal @employee.job_title.name, @result[:job_title]
  end

  test "resolves department name" do
    assert_equal @employee.department.name, @result[:department]
  end

  test "includes country" do
    assert_equal @employee.country, @result[:country]
  end

  test "serialises salary as a string" do
    assert_instance_of String, @result[:salary]
    assert_equal @employee.salary.to_s, @result[:salary]
  end

  test "includes currency" do
    assert_equal @employee.currency, @result[:currency]
  end

  test "includes employment_type" do
    assert_equal @employee.employment_type, @result[:employment_type]
  end

  test "includes hired_on as an ISO 8601 date string" do
    assert_equal @employee.hired_on.iso8601, @result[:hired_on]
  end

  # — Sensitive fields excluded —————————————————————————————————————————————

  test "does not include deleted_at" do
    assert_not @result.key?(:deleted_at)
  end

  test "does not include job_title_id" do
    assert_not @result.key?(:job_title_id)
  end

  test "does not include department_id" do
    assert_not @result.key?(:department_id)
  end
end
