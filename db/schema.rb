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

ActiveRecord::Schema[8.1].define(version: 2026_04_13_075258) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "country", limit: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.datetime "deleted_at"
    t.string "department", null: false
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
    t.index ["department"], name: "idx_employees_department"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["job_title_id"], name: "index_employees_on_job_title_id"
  end

  create_table "job_titles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_job_titles_on_name", unique: true
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

  add_foreign_key "employees", "job_titles"
end
