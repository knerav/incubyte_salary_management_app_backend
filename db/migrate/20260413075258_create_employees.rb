class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name,       null: false
      t.string :last_name,        null: false
      t.string :email,            null: false
      t.references :job_title,    null: false, foreign_key: true
      t.string :department,       null: false
      t.string :country,          limit: 2, null: false
      t.decimal :salary,          precision: 15, scale: 2, null: false
      t.string :currency,         null: false, default: "USD"
      t.string :employment_type,  null: false
      t.date :hired_on,           null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :employees, :email,                        unique: true
    add_index :employees, :department,                   name: "idx_employees_department"
    add_index :employees, :country,                      name: "idx_employees_country"
    add_index :employees, %i[country job_title_id],      name: "idx_employees_country_job_title"
    add_index :employees, :deleted_at,                   name: "idx_employees_deleted_at"
  end
end
