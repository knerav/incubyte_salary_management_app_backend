class Employee < ApplicationRecord
  EMPLOYMENT_TYPES = %w[full_time part_time contract].freeze

  belongs_to :job_title
  has_many :salary_histories

  default_scope { where(deleted_at: nil) }

  validates :first_name,       presence: true
  validates :last_name,        presence: true
  validates :email,            presence: true, uniqueness: true
  validates :department,       presence: true
  validates :country,          presence: true
  validates :salary,           presence: true, numericality: { greater_than: 0 }
  validates :currency,         presence: true
  validates :employment_type,  presence: true, inclusion: { in: EMPLOYMENT_TYPES }
  validates :hired_on,         presence: true

  after_update :record_salary_history, if: :saved_change_to_salary?

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def record_salary_history
    salary_histories.create!(
      salary: salary,
      currency: currency,
      effective_from: Date.today
    )
  end
end
