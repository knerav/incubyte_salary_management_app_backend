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
│   │   ├── pages_controller.rb          ← Hotwire (home / future dashboard)
│   │   ├── employees_controller.rb      ← Hotwire (HTML responses)
│   │   ├── insights_controller.rb       ← Hotwire (HTML responses)
│   │   └── api/
│   │       └── v1/
│   │           ├── base_controller.rb       ← authenticate_user!, JWT strategy
│   │           ├── employees_controller.rb
│   │           ├── auth/
│   │           │   ├── sessions_controller.rb      ← sign in → returns JWT
│   │           │   └── registrations_controller.rb ← sign up via API
│   │           └── insights/
│   │               └── salary_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── employee.rb
│   │   └── salary_history.rb
│   ├── serializers/
│   │   ├── employee_serializer.rb
│   │   └── insights/
│   │       ├── salary_insights_serializer.rb
│   │       └── historical_salary_serializer.rb
│   ├── services/
│   │   ├── employees/
│   │   │   └── filter_service.rb
│   │   └── insights/
│   │       ├── salary_insights_service.rb
│   │       └── historical_salary_service.rb
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb     ← Main app layout (authenticated pages)
│       │   └── devise.html.erb          ← Auth layout (sign in, sign up, password reset)
│       ├── devise/
│       │   ├── sessions/
│       │   │   └── new.html.erb             ← Sign in form
│       │   ├── registrations/
│       │   │   ├── new.html.erb             ← Sign up form
│       │   │   └── edit.html.erb            ← Edit account form
│       │   ├── passwords/
│       │   │   ├── new.html.erb             ← Forgot password form
│       │   │   └── edit.html.erb            ← Reset password form
│       │   └── shared/
│       │       ├── _error_messages.html.erb
│       │       └── _links.html.erb
│       ├── pages/
│       │   └── home.html.erb            ← Homepage / future dashboard
│       ├── employees/
│       │   ├── index.html.erb
│       │   ├── show.html.erb
│       │   ├── new.html.erb
│       │   └── edit.html.erb
│       └── insights/
│           └── index.html.erb
├── db/
│   ├── migrate/
│   ├── schema.rb
│   └── seeds/
│       ├── seed.rb
│       ├── first_names.txt
│       └── last_names.txt
├── test/
│   ├── models/
│   │   ├── user_test.rb
│   │   ├── employee_test.rb
│   │   └── salary_history_test.rb
│   ├── integration/
│   │   ├── pages_test.rb                ← Homepage auth guard + render
│   │   ├── employees_test.rb            ← Employees auth guard + render
│   │   ├── insights_test.rb             ← Insights auth guard + render
│   │   ├── users/
│   │   │   ├── sessions_test.rb         ← Sign in / sign out flows
│   │   │   └── registrations_test.rb    ← Sign up flow
│   │   └── api/
│   │       └── v1/
│   │           ├── employees_test.rb
│   │           └── insights/
│   │               └── salary_test.rb
│   ├── services/
│   │   ├── employees/
│   │   │   └── filter_service_test.rb
│   │   └── insights/
│   │       ├── salary_insights_service_test.rb
│   │       └── historical_salary_service_test.rb
│   ├── serializers/
│   │   └── employee_serializer_test.rb
│   ├── system/                          ← Placeholder; no system tests at this stage
│   └── fixtures/
│       ├── users.yml
│       ├── employees.yml
│       └── salary_histories.yml
└── config/
    └── routes.rb
```

I put complex business logic — insights aggregations and employee filtering — in `app/services/` rather than in controllers or models. This keeps models focused on state and validations, and makes the business logic independently testable.

I handle JSON rendering with PORO serializer classes in `app/serializers/` rather than inline `render json:` calls in controllers. This makes the response shape explicit and testable without coupling it to the controller.

I test API endpoints via `test/integration/api/` rather than `test/controllers/`. Integration tests exercise the full stack through the router, which is closer to how the API is actually consumed. Controller tests miss routing and middleware concerns.

Hotwire views follow the same pattern — integration tests in `test/integration/` cover the auth guard and the happy-path render for each page. The underlying business logic is covered by service tests, not re-tested at the view layer.

I'm using Rails fixtures (YAML) for test data rather than FactoryBot. Fixtures are the Rails default, fast, and deterministic — no additional dependency needed.

I keep the seed script and source name files together in `db/seeds/` rather than inlining everything into `db/seeds.rb`, keeping the seeds directory self-contained.

---

### Controller hierarchy

```
ApplicationController           (authenticate_user!, after_sign_out_path_for)
├── PagesController             (Hotwire — home / future dashboard)
├── EmployeesController         (Hotwire)
├── InsightsController          (Hotwire)
└── Api::V1::BaseController     (JWT strategy)
    ├── Api::V1::Auth::SessionsController
    ├── Api::V1::Auth::RegistrationsController
    ├── Api::V1::EmployeesController
    └── Api::V1::Insights::SalaryController
```

`authenticate_user!` lives in `ApplicationController` and protects all Hotwire pages. Devise controllers are exempted automatically. `Api::V1::BaseController` inherits the same guard but applies it via the JWT strategy for the JSON API.

The Devise `users/sessions`, `users/registrations`, and `users/passwords` controller overrides were originally planned to handle Turbo form responses. Devise 5.0 resolved this natively via the `responders` gem — those overrides are no longer needed and have been omitted.

---

### Routes shape

```ruby
devise_for :users

root "pages#home"

resources :employees do
  member { patch :salary }
end

get "insights", to: "insights#index"

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
