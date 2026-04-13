require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  # — Validity ——————————————————————————————————————————————————————————————

  test "is valid with a unique name" do
    department = Department.new(name: "Finance")
    assert department.valid?
  end

  # — Name validations ——————————————————————————————————————————————————————

  test "is invalid without a name" do
    department = Department.new(name: "")
    assert_not department.valid?
    assert_includes department.errors[:name], "can't be blank"
  end

  test "is invalid with a duplicate name" do
    department = Department.new(name: departments(:engineering).name)
    assert_not department.valid?
    assert_includes department.errors[:name], "has already been taken"
  end

  test "is invalid with a duplicate name regardless of case" do
    department = Department.new(name: departments(:engineering).name.upcase)
    assert_not department.valid?
    assert_includes department.errors[:name], "has already been taken"
  end

  # — Associations ——————————————————————————————————————————————————————————

  test "has many employees" do
    assert_respond_to departments(:engineering), :employees
  end

  # — Deletion guard ————————————————————————————————————————————————————————

  test "can be destroyed when no employees are assigned" do
    assert departments(:qa).destroy
  end

  test "cannot be destroyed when employees are assigned" do
    department = departments(:engineering)
    assert_not department.destroy
    assert department.persisted?
    assert_includes department.errors[:base], "Cannot delete department with assigned employees"
  end
end
