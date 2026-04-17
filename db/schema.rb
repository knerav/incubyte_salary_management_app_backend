# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_17_055227) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.string "country", limit: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.datetime "deleted_at"
    t.bigint "department_id", null: false
    t.string "email", null: false
    t.string "employment_type", null: false
    t.string "first_name", null: false
    t.date "hired_on", null: false
    t.bigint "job_title_id", null: false
    t.string "last_name", null: false
    t.decimal "salary", precision: 15, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["country", "job_title_id"], name: "idx_employees_country_job_title"
    t.index ["country"], name: "idx_employees_country"
    t.index ["deleted_at"], name: "idx_employees_deleted_at"
    t.index ["department_id"], name: "idx_employees_department_id"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["job_title_id"], name: "index_employees_on_job_title_id"
  end

  create_table "job_titles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_job_titles_on_name", unique: true
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "salary_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.date "effective_from", null: false
    t.bigint "employee_id", null: false
    t.decimal "salary", precision: 15, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["effective_from"], name: "idx_salary_histories_effective_from"
    t.index ["employee_id", "effective_from"], name: "idx_salary_histories_employee_effective"
    t.index ["employee_id"], name: "index_salary_histories_on_employee_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "employees", "departments"
  add_foreign_key "employees", "job_titles"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "salary_histories", "employees"
end
