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
│   │   ├── application_controller.rb
│   │   ├── employees_controller.rb       ← Hotwire (HTML responses)
│   │   ├── insights_controller.rb        ← Hotwire (HTML responses)
│   │   └── api/
│   │       └── v1/
│   │           ├── employees_controller.rb
│   │           └── insights/
│   │               └── salary_controller.rb
│   ├── models/
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
│       ├── employees/
│       │   ├── index.html.erb
│       │   ├── show.html.erb
│       │   ├── new.html.erb
│       │   └── edit.html.erb
│       └── insights/
│           └── index.html.erb
├── db/
│   ├── migrate/
│   └── seeds/
│       ├── seed.rb
│       ├── first_names.txt
│       └── last_names.txt
├── test/
│   ├── models/
│   │   ├── employee_test.rb
│   │   └── salary_history_test.rb
│   ├── integration/
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
│   └── fixtures/
│       ├── employees.yml
│       └── salary_histories.yml
└── config/
    └── routes.rb
```

I put complex business logic — insights aggregations and employee filtering — in `app/services/` rather than in controllers or models. This keeps models focused on state and validations, and makes the business logic independently testable.

I handle JSON rendering with PORO serializer classes in `app/serializers/` rather than inline `render json:` calls in controllers. This makes the response shape explicit and testable without coupling it to the controller.

I test API endpoints via `test/integration/` rather than `test/controllers/`. Integration tests exercise the full stack through the router, which is closer to how the API is actually consumed. Controller tests miss routing and middleware concerns.

I'm using Rails fixtures (YAML) for test data rather than FactoryBot. Fixtures are the Rails default, fast, and deterministic — no additional dependency needed.

I keep the seed script and source name files together in `db/seeds/` rather than inlining everything into `db/seeds.rb`, keeping the seeds directory self-contained.

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
