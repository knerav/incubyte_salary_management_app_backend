# =============================================================================
# Seeds
# Idempotent — safe to run multiple times via bin/rails db:seed
# =============================================================================

# — HR User ———————————————————————————————————————————————————————————————————

User.find_or_create_by!(email: "hr@incubyte.co") do |user|
  user.password              = "Password1!"
  user.password_confirmation = "Password1!"
end

puts "✓ HR user"

# — Job Titles ————————————————————————————————————————————————————————————————

JOB_TITLES = [
  "Software Engineer",
  "Senior Software Engineer",
  "Technical Lead",
  "Engineering Manager",
  "DevOps Engineer",
  "QA Engineer",
  "Product Manager",
  "Business Analyst",
  "Scrum Master",
  "Data Analyst",
  "Designer",
  "HR Manager"
].freeze

JOB_TITLES.each { |name| JobTitle.find_or_create_by!(name: name) }

puts "✓ Job titles (#{JOB_TITLES.size})"

# — Departments ———————————————————————————————————————————————————————————————

DEPARTMENTS = [
  "Engineering",
  "Product",
  "Design",
  "QA",
  "HR",
  "Finance",
  "Marketing",
  "Operations"
].freeze

DEPARTMENTS.each { |name| Department.find_or_create_by!(name: name) }

puts "✓ Departments (#{DEPARTMENTS.size})"

# — Employees —————————————————————————————————————————————————————————————————

COUNTRIES_WITH_CURRENCIES = {
  "US" => "USD",
  "GB" => "GBP",
  "IN" => "INR",
  "DE" => "EUR",
  "FR" => "EUR",
  "CA" => "CAD",
  "AU" => "AUD",
  "SG" => "SGD",
  "AE" => "AED",
  "NG" => "NGN"
}.freeze

SALARY_RANGE = (40_000..180_000).freeze

db_dir       = File.expand_path(".", __dir__)
first_names  = File.readlines("#{db_dir}/first_names.txt").map(&:chomp).reject(&:empty?).uniq
last_names   = File.readlines("#{db_dir}/last_names.txt").map(&:chomp).reject(&:empty?).uniq

job_title_ids  = JobTitle.pluck(:id)
department_ids = Department.pluck(:id)
countries      = COUNTRIES_WITH_CURRENCIES.keys
rng            = Random.new(42)

name_pairs = first_names.product(last_names).shuffle(random: rng).first(10_000)

now = Time.current

employees = name_pairs.map do |first, last|
  country  = countries.sample(random: rng)
  currency = COUNTRIES_WITH_CURRENCIES[country]

  {
    first_name:      first,
    last_name:       last,
    email:           "#{first.downcase}.#{last.downcase.gsub(/\s+/, "")}@company.com",
    job_title_id:    job_title_ids.sample(random: rng),
    department_id:   department_ids.sample(random: rng),
    country:         country,
    salary:          rng.rand(SALARY_RANGE),
    currency:        currency,
    employment_type: Employee::EMPLOYMENT_TYPES.sample(random: rng),
    hired_on:        Date.new(rng.rand(2015..2024), rng.rand(1..12), rng.rand(1..28)),
    deleted_at:      nil,
    created_at:      now,
    updated_at:      now
  }
end

Employee.upsert_all(employees, unique_by: :email, update_only: %i[
  first_name last_name job_title_id department_id
  country salary currency employment_type hired_on
])

puts "✓ Employees (#{employees.size})"
