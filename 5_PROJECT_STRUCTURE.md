# Project Structure

I'm building two applications — a Rails monolith and a Next.js frontend — each in its own repository. Separate repositories keep the commit histories focused and make it easier to evaluate each application independently.

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
│   │   ├── pages_controller.rb          ← Hotwire (home)
│   │   ├── job_titles_controller.rb     ← Hotwire (full CRUD)
│   │   ├── departments_controller.rb    ← Hotwire (full CRUD)
│   │   ├── employees_controller.rb      ← Hotwire (full CRUD + salary action)
│   │   ├── insights_controller.rb       ← Hotwire (filter + aggregations)
│   │   └── api/                         ← [not yet implemented]
│   │       └── v1/
│   │           ├── base_controller.rb
│   │           ├── employees_controller.rb
│   │           ├── auth/
│   │           │   ├── sessions_controller.rb
│   │           │   └── registrations_controller.rb
│   │           └── insights/
│   │               └── salary_controller.rb
│   ├── models/
│   │   ├── user.rb                      ← Devise, JTIMatcher, trackable
│   │   ├── job_title.rb                 ← presence/uniqueness validations, deletion guard
│   │   ├── department.rb                ← presence/uniqueness validations, deletion guard
│   │   ├── employee.rb                  ← validations, soft delete scope, full_name,
│   │   │                                   salary history callback
│   │   └── salary_history.rb            ← validations, before_update immutability guard
│   ├── serializers/                     ← [not yet implemented]
│   │   ├── employee_serializer.rb
│   │   └── insights/
│   │       ├── salary_insights_serializer.rb
│   │       └── historical_salary_serializer.rb
│   ├── services/                        ← [not yet implemented]
│   │   ├── employees/
│   │   │   └── filter_service.rb
│   │   └── insights/
│   │       ├── salary_insights_service.rb
│   │       └── historical_salary_service.rb
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb     ← Main app layout (authenticated pages)
│       │   └── devise.html.erb          ← Auth layout (sign in, sign up, password reset)
│       ├── shared/
│       │   └── _navbar.html.erb         ← Logo, nav links (Home, Employees, Job Titles,
│       │                                   Departments, Insights), sign out button
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
│       │   └── home.html.erb
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
│       │   ├── index.html.erb
│       │   ├── show.html.erb            ← profile + inline salary update form
│       │   ├── new.html.erb
│       │   ├── edit.html.erb
│       │   └── _form.html.erb
│       └── insights/
│           └── index.html.erb           ← filter bar, summary stats, job title breakdown
├── db/
│   ├── migrate/
│   │   ├── 20260412163853_devise_create_users.rb
│   │   ├── 20260413073224_create_job_titles.rb
│   │   ├── 20260413075258_create_employees.rb
│   │   ├── 20260413104507_create_salary_histories.rb
│   │   ├── 20260413164738_create_departments.rb
│   │   └── 20260413164739_add_department_to_employees.rb
│   ├── schema.rb
│   └── seeds.rb                         ← seeds default HR Manager user
├── test/
│   ├── models/
│   │   ├── user_test.rb
│   │   ├── job_title_test.rb
│   │   ├── department_test.rb
│   │   ├── employee_test.rb
│   │   └── salary_history_test.rb
│   ├── integration/
│   │   ├── pages_test.rb
│   │   ├── job_titles_test.rb
│   │   ├── departments_test.rb
│   │   ├── employees_test.rb
│   │   ├── insights_test.rb
│   │   ├── user_sessions_test.rb
│   │   ├── user_registrations_test.rb
│   │   └── api/                         ← [not yet implemented]
│   │       └── v1/
│   │           ├── employees_test.rb
│   │           └── insights/
│   │               └── salary_test.rb
│   ├── services/                        ← [not yet implemented]
│   │   ├── employees/
│   │   │   └── filter_service_test.rb
│   │   └── insights/
│   │       ├── salary_insights_service_test.rb
│   │       └── historical_salary_service_test.rb
│   ├── serializers/                     ← [not yet implemented]
│   │   └── employee_serializer_test.rb
│   ├── system/                          ← placeholder; no system tests at this stage
│   └── fixtures/
│       ├── users.yml
│       ├── job_titles.yml
│       ├── departments.yml
│       ├── employees.yml                ← john_doe, jane_smith, deleted_employee
│       └── salary_histories.yml         ← two entries for john_doe, one for jane_smith
└── config/
    └── routes.rb
```

---

### Controller hierarchy

```
ApplicationController                 (authenticate_user!, after_sign_out_path_for)
├── PagesController                   (Hotwire — home)
├── JobTitlesController               (Hotwire — full CRUD)
├── DepartmentsController             (Hotwire — full CRUD)
├── EmployeesController               (Hotwire — full CRUD + salary action)
├── InsightsController                (Hotwire — filter + SQL aggregations)
└── Api::V1::BaseController           (JWT strategy) [not yet implemented]
    ├── Api::V1::Auth::SessionsController
    ├── Api::V1::Auth::RegistrationsController
    ├── Api::V1::EmployeesController
    └── Api::V1::Insights::SalaryController
```

`authenticate_user!` lives in `ApplicationController` and protects all Hotwire pages. Devise controllers are exempted automatically. `Api::V1::BaseController` will inherit the same guard but apply it via the JWT strategy for the JSON API.

The Devise `users/sessions`, `users/registrations`, and `users/passwords` controller overrides were originally planned to handle Turbo form responses. Devise 5.0 resolved this natively via the `responders` gem — those overrides are no longer needed and have been omitted.

---

### Routes shape

```ruby
devise_for :users

root "pages#home"

resources :job_titles
resources :departments

resources :employees do
  member { patch :salary }
end

get "insights", to: "insights#index"

# Not yet implemented:
namespace :api do
  namespace :v1 do
    devise_for :users, controllers: {
      sessions:      'api/v1/auth/sessions',
      registrations: 'api/v1/auth/registrations'
    }

    resources :employees do
      member { patch :salary }
    end

    namespace :insights do
      resource :salary, only: [:show] do
        get :history, on: :collection
      end
    end
  end
end
```

---

## Design notes

I put complex business logic — insights aggregations and employee filtering — in `app/services/` rather than in controllers or models. This keeps models focused on state and validations, and makes the business logic independently testable.

I handle JSON rendering with PORO serializer classes in `app/serializers/` rather than inline `render json:` calls in controllers. This makes the response shape explicit and testable without coupling it to the controller.

I test Hotwire endpoints via `test/integration/` rather than `test/controllers/`. Integration tests exercise the full stack through the router, which is closer to how the application is actually consumed. Controller tests miss routing and middleware concerns.

I'm using Rails fixtures (YAML) for test data rather than FactoryBot. Fixtures are the Rails default, fast, and deterministic — no additional dependency needed.

---

## Next.js App

```
incubyte-salary-management-ui/
├── app/
│   ├── employees/
│   │   ├── page.tsx                  ← Employee list
│   │   ├── new/
│   │   │   └── page.tsx              ← Add employee
│   │   └── [id]/
│   │       ├── page.tsx              ← Employee profile
│   │       └── edit/
│   │           └── page.tsx          ← Edit employee
│   └── insights/
│       └── page.tsx                  ← Salary insights dashboard
├── components/
│   ├── employees/
│   │   ├── EmployeeTable.tsx
│   │   ├── EmployeeForm.tsx
│   │   └── EmployeeCard.tsx
│   └── insights/
│       ├── SalaryInsightsPanel.tsx
│       └── SalaryHistoryChart.tsx
├── lib/
│   └── api.ts                        ← Typed API client (fetch wrappers)
└── types/
    └── index.ts                      ← Shared TypeScript types
```

I centralise all API calls in `lib/api.ts` — a single typed client rather than scattered fetch calls across components. Base URL, headers, and error handling are configured in one place.

I define TypeScript types for `Employee`, `SalaryInsights`, and `HistoricalSalaryInsights` once in `types/index.ts` and share them across components and the API client. Any mismatch between the API contract and the frontend surfaces as a type error at compile time.
