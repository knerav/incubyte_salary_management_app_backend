class Department < ApplicationRecord
  has_many :employees

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :prevent_destroy_with_employees

  private

  def prevent_destroy_with_employees
    return unless Employee.unscoped.where(department_id: id).exists?

    errors.add(:base, "Cannot delete department with assigned employees")
    throw :abort
  end
end
