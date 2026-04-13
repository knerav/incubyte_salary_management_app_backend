require "test_helper"

class JobTitleTest < ActiveSupport::TestCase
  # — Validity —————————————————————————————————————————————————————————————

  test "is valid with a unique name" do
    job_title = JobTitle.new(name: "Engineering Manager")
    assert job_title.valid?
  end

  # — Name validations ——————————————————————————————————————————————————————

  test "is invalid without a name" do
    job_title = JobTitle.new(name: "")
    assert_not job_title.valid?
    assert_includes job_title.errors[:name], "can't be blank"
  end

  test "is invalid with a duplicate name" do
    job_title = JobTitle.new(name: job_titles(:software_engineer).name)
    assert_not job_title.valid?
    assert_includes job_title.errors[:name], "has already been taken"
  end

  test "is invalid with a duplicate name regardless of case" do
    job_title = JobTitle.new(name: job_titles(:software_engineer).name.upcase)
    assert_not job_title.valid?
    assert_includes job_title.errors[:name], "has already been taken"
  end

  # — Associations ——————————————————————————————————————————————————————————

  test "has many employees" do
    assert_respond_to job_titles(:software_engineer), :employees
  end

  # — Deletion guard ————————————————————————————————————————————————————————

  test "can be destroyed when no employees are assigned" do
    assert job_titles(:qa_engineer).destroy
  end

  test "cannot be destroyed when employees are assigned" do
    job_title = job_titles(:software_engineer)
    assert_not job_title.destroy
    assert job_title.persisted?
    assert_includes job_title.errors[:base], "Cannot delete job title with assigned employees"
  end
end
