class CreateSalaryHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_histories do |t|
      t.references :employee,      null: false, foreign_key: true
      t.decimal :salary,           precision: 15, scale: 2, null: false
      t.string :currency,          null: false
      t.date :effective_from,      null: false

      t.timestamps
    end

    add_index :salary_histories, :effective_from,
              name: "idx_salary_histories_effective_from"
    add_index :salary_histories, %i[employee_id effective_from],
              name: "idx_salary_histories_employee_effective"
  end
end
