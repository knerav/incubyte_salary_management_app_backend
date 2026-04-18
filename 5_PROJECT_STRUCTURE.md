# Project Structure

I'm building two applications, a Rails monolith and a Next.js frontend — each in its own repository. Separate repositories keep the commit histories focused and make it easier to evaluate each application independently.

> I would not ordinarily choose such a structure for an actual application. But, for the scope of this assignment I wanted to show you that I'm comfortable working with a traditional rails monolith (using modern Hotwire view standards), and also separate backend and frontend apps.

---

## Repositories

```
incubyte-salary-management/       ← Rails monolith (backend + Hotwire)
incubyte-salary-management-ui/    ← Next.js frontend
```

---

## Rails App

```
incubyte-salary-management/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb    ← authenticate_user!, after_sign_out_path_for
│   │   ├── pages_controller.rb          ← Hotwire (organisation_settings only)
│   │   ├── job_titles_controller.rb     ← Hotwire (full CRUD)
│   │   ├── departments_controller.rb    ← Hotwire (full CRUD)
│   │   ├── employees_controller.rb      ← Hotwire (full CRUD + salary action)
│   │   ├── insights_controller.rb       ← Hotwire (filter + aggregations)
│   │   └── api/
│   │       └── v1/
│   │           ├── base_controller.rb   ← current_user guard, render helpers
│   │           ├── employees_controller.rb  ← JSON CRUD + salary action
│   │           ├── job_titles_controller.rb  ← full CRUD
│   │           ├── departments_controller.rb ← full CRUD
│   │           ├── countries_controller.rb   ← index (active employees only)
│   │           ├── auth/
│   │           │   ├── sessions_controller.rb   ← returns refresh token in body on sign-in
│   │           │   ├── registrations_controller.rb
│   │           │   └── tokens_controller.rb     ← body auth, rotation, new JWT
│   │           └── insights/
│   │               └── salary_controller.rb  ← index
│   ├── helpers/
│   │   └── application_helper.rb        ← country_options, currency_options,
│   │                                       salary_change_percentage
│   ├── lib/
│   │   ├── api_failure_app.rb           ← Warden failure app — returns JSON 401 for /api/ paths
│   │   └── currency_lookup.rb           ← ISO 3166 currency code/symbol helpers
│   ├── models/
│   │   ├── user.rb                      ← Devise, JTIMatcher, trackable
│   │   ├── job_title.rb                 ← presence/uniqueness validations, deletion guard
│   │   ├── department.rb                ← presence/uniqueness validations, deletion guard
│   │   ├── employee.rb                  ← validations, soft delete scope, full_name,
│   │   │                                   ransackable_attributes, full_name_cont scope,
│   │   │                                   salary history callback
│   │   ├── salary_history.rb            ← validations, before_update immutability guard
│   │   └── refresh_token.rb             ← belongs_to user; generate_for, find_active_by_token;
│   │                                       stores SHA-256 digest, never the raw token
│   ├── serializers/
│   │   ├── employee_serializer.rb
│   │   ├── salary_history_serializer.rb  ← per-employee history with change percentages
│   │   └── salary_insights_serializer.rb
│   ├── services/
│   │   ├── employee_filter_service.rb
│   │   └── salary_insights_service.rb
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb     ← Main app layout (authenticated pages)
│       │   └── devise.html.erb          ← Auth layout (sign in, sign up, password reset)
│       ├── shared/
│       │   ├── _navbar.html.erb         ← Logo (links to root), nav links (Employees,
│       │   │                               Insights, Settings), profile dropdown
│       │   ├── _flash.html.erb          ← Reusable flash notice/alert partial
│       │   └── _alert.html.erb
│       ├── devise/
│       │   ├── sessions/
│       │   │   └── new.html.erb
│       │   ├── registrations/
│       │   │   ├── new.html.erb
│       │   │   └── edit.html.erb
│       │   ├── passwords/
│       │   │   ├── new.html.erb
│       │   │   └── edit.html.erb
│       │   └── shared/
│       │       ├── _error_messages.html.erb
│       │       └── _links.html.erb
│       ├── pages/
│       │   └── organisation_settings.html.erb  ← card links to Job Titles and Departments
│       ├── job_titles/
│       │   ├── index.html.erb
│       │   ├── new.html.erb
│       │   ├── edit.html.erb
│       │   └── _form.html.erb
│       ├── departments/
│       │   ├── index.html.erb
│       │   ├── new.html.erb
│       │   ├── edit.html.erb
│       │   └── _form.html.erb
│       ├── employees/
│       │   ├── index.html.erb           ← search bar (full-name), pagination, employee list
│       │   ├── show.html.erb            ← profile, salary history table, salary update form
│       │   ├── new.html.erb
│       │   ├── edit.html.erb
│       │   ├── _form.html.erb           ← country + currency select dropdowns
│       │   ├── _employee.html.erb
│       │   ├── _modal.html.erb
│       │   ├── create.turbo_stream.erb
│       │   ├── update.turbo_stream.erb
│       │   ├── salary.turbo_stream.erb
│       │   └── destroy.turbo_stream.erb
│       └── insights/
│           └── index.html.erb           ← filter bar, summary stats, job title breakdown
├── db/
│   ├── migrate/
│   │   ├── 20260412163853_devise_create_users.rb
│   │   ├── 20260413073224_create_job_titles.rb
│   │   ├── 20260413075258_create_employees.rb
│   │   ├── 20260413104507_create_salary_histories.rb
│   │   ├── 20260413164738_create_departments.rb
│   │   ├── 20260413164739_add_department_to_employees.rb
│   │   └── 20260417055227_create_refresh_tokens.rb
│   ├── schema.rb
│   └── seeds.rb                         ← 10 000 employees via upsert_all; idempotent
├── lib/
│   └── tasks/
│       └── backfill_salary_histories.rake  ← one-time backfill for upsert-seeded employees
├── test/
│   ├── models/
│   │   ├── user_test.rb
│   │   ├── job_title_test.rb
│   │   ├── department_test.rb
│   │   ├── employee_test.rb
│   │   ├── salary_history_test.rb
│   │   └── refresh_token_test.rb
│   ├── integration/
│   │   ├── organisation_settings_test.rb
│   │   ├── job_titles_test.rb
│   │   ├── departments_test.rb
│   │   ├── employees_test.rb
│   │   ├── insights_test.rb
│   │   ├── user_account_test.rb
│   │   ├── users/
│   │   │   ├── sessions_test.rb
│   │   │   └── registrations_test.rb
│   │   └── api/
│   │       └── v1/
│   │           ├── employees_test.rb
│   │           ├── job_titles_test.rb
│   │           ├── departments_test.rb
│   │           ├── countries_test.rb
│   │           ├── insights/
│   │           │   └── salary_test.rb
│   │           └── auth/
│   │               ├── sessions_test.rb ← sign-in/sign-out, refresh token in body
│   │               └── tokens_test.rb   ← refresh token rotation flow
│   ├── services/
│   │   ├── employee_filter_service_test.rb
│   │   └── salary_insights_service_test.rb
│   ├── serializers/
│   │   ├── employee_serializer_test.rb
│   │   ├── salary_history_serializer_test.rb
│   │   └── salary_insights_serializer_test.rb
│   ├── tasks/
│   │   └── backfill_salary_histories_test.rb
│   ├── system/                          ← placeholder; no system tests at this stage
│   └── fixtures/
│       ├── users.yml
│       ├── job_titles.yml
│       ├── departments.yml
│       ├── employees.yml                ← john_doe, jane_smith, deleted_employee
│       └── salary_histories.yml         ← two entries each for john_doe and jane_smith
└── config/
    └── routes.rb
```

---

### Controller hierarchy

```
ApplicationController                 (authenticate_user!, after_sign_out_path_for)
├── PagesController                   (Hotwire — organisation_settings)
├── JobTitlesController               (Hotwire — full CRUD)
├── DepartmentsController             (Hotwire — full CRUD)
├── EmployeesController               (Hotwire — full CRUD + salary action)
├── InsightsController                (Hotwire — filter + SQL aggregations)
└── Api::V1::BaseController           (current_user guard, render helpers)
    ├── Api::V1::Auth::SessionsController
    ├── Api::V1::Auth::RegistrationsController
    ├── Api::V1::EmployeesController
    ├── Api::V1::JobTitlesController
    ├── Api::V1::DepartmentsController
    ├── Api::V1::CountriesController
    └── Api::V1::Insights::SalaryController

ActionController::API                 (no authentication — auth via refresh token in request body)
└── Api::V1::Auth::TokensController   (POST /api/v1/users/refresh)
```

`authenticate_user!` lives in `ApplicationController` and protects all Hotwire pages. Devise controllers are exempted automatically. `Api::V1::BaseController` uses `current_user` (non-throwing) to guard API endpoints — this avoids Warden's failure app, which would redirect to the HTML sign-in page rather than returning a JSON 401. The API uses `devise_scope :user` to route auth endpoints through the existing `:user` Warden scope, keeping JWT dispatch, revocation, and authentication all aligned.

`Api::V1::Auth::TokensController` sits outside `BaseController` intentionally — the refresh endpoint authenticates via the refresh token in the request body, not a JWT. Inheriting `BaseController` would require a valid JWT, defeating the purpose of the endpoint.

The Devise `users/sessions`, `users/registrations`, and `users/passwords` controller overrides were originally planned to handle Turbo form responses. Devise 5.0 resolved this natively via the `responders` gem — those overrides are no longer needed and have been omitted.

---

### Routes shape

```ruby
devise_for :users

root "employees#index"

get "organisation_settings", to: "pages#organisation_settings"

resources :job_titles
resources :departments

resources :employees do
  member { patch :salary }
end

get "insights", to: "insights#index"

namespace :api do
  namespace :v1 do
    devise_scope :user do
      post   "users/sign_in",  to: "auth/sessions#create"
      delete "users/sign_out", to: "auth/sessions#destroy"
      post   "users",          to: "auth/registrations#create"
      post   "users/refresh",  to: "auth/tokens#create"
    end

    resources :employees do
      member do
        patch :salary
        get   :salary_history
      end
    end

    resources :job_titles
    resources :departments
    resources :countries,    only: [:index]

    namespace :insights do
      resources :salary, only: [:index]
    end
  end
end
```

---

## Design notes

Complex business logic — insights aggregations and employee filtering — goes in `app/services/` rather than in controllers or models. This keeps models focused on state and validations, and makes the business logic independently testable.

JSON rendering is handled with PORO serializer classes in `app/serializers/` rather than inline `render json:` calls in controllers. This makes the response shape explicit and testable without coupling it to the controller.

Hotwire/view endpoints are tested via `test/integration/` rather than `test/controllers/`. Integration tests exercise the full stack through the router, which is closer to how the application is actually consumed. Controller tests miss routing and middleware concerns.

I'm using the default Rails fixtures (YAML) for test data.
