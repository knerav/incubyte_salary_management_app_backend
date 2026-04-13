class AddDepartmentToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_reference :employees, :department, null: true, foreign_key: true

    remove_index  :employees, name: "idx_employees_department"
    remove_column :employees, :department, :string

    # Null: false applied after column swap. For a table with existing rows,
    # department_id must be backfilled before this step.
    change_column_null :employees, :department_id, false

    add_index :employees, :department_id, name: "idx_employees_department_id"
  end
end
