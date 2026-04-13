class SalaryHistory < ApplicationRecord
  belongs_to :employee

  validates :salary,         presence: true, numericality: { greater_than: 0 }
  validates :currency,       presence: true
  validates :effective_from, presence: true

  before_update { throw :abort }
end
