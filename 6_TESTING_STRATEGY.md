# Testing Strategy

The assignment asks for tests that are fast, deterministic, and easy to understand. Those three constraints directly informed every choice I made here.

I'm following a strict TDD cycle — red, green, refactor — throughout the Rails codebase. Adopting an inside-out approach: model tests first, then integration tests for the Hotwire layer, then services and serializers for the JSON API layer. Outside-in TDD (starting from integration tests and working inward) makes more sense when requirements are still being discovered. Here, the requirements were already thoroughly worked through during event storming and captured in the data model and API contract, so inside-out lets me move faster with tighter, more focused test cycles.

Even infrastructure concerns like migrations follow the TDD cycle. Rather than writing migrations speculatively upfront, each migration is driven by a failing test — the test failure is the red state that makes the migration necessary.

---

## Framework and test data

I'm using Minitest — the Rails default — with no additional testing frameworks. I manage test data with Rails fixtures (YAML).

---

## Testing Order

### 1. Models — `test/models/`

Model tests cover validations, associations, and scopes — anything that enforces data integrity or shapes how records are queried.

### 2. Integration tests (Hotwire) — `test/integration/`

With the models in place, next are integration tests for each resource's CRUD actions rather than isolated controller tests. Integration tests exercise the full stack through the router — routing, authentication guards, parameter handling, response codes, and redirects — which is closer to how the Hotwire frontend actually exercises the application. Controller tests in isolation would miss these concerns without adding meaningful coverage.

Each integration test suite is written before the controller and views exist, providing the red state that drives their implementation.

Hotwire-specific behaviour is tested here too — Turbo Frame responses, Turbo Stream templates (create, update, salary, destroy), flash notice injection, modal rendering, search form structure, pagination nav presence, and dropdown population. These tests assert on rendered HTML and response media type rather than relying on manual verification.

### 3. Services — `test/services/`

The service objects encapsulate the core business logic — salary aggregations, historical trend queries, and employee filtering. Testing these directly makes failures easy to diagnose.

Specific cases covered:

- `SalaryInsightsService` returns correct min, max, and average for a given filter combination
- `HistoricalSalaryService` groups salary data correctly by month, quarter, and year
- `EmployeeFilterService` applies multiple filters additively and respects the soft delete scope
- Edge cases: a country or department with a single employee, a date range with no salary history records

### 4. Integration tests — `test/integration/`

Integration tests come last and exercise the full API stack — through the router, controller, service, and serializer — asserting on status codes and response shapes.

Key cases covered per endpoint:

- Happy path returns the expected status code and response shape
- Invalid parameters return a `422` with a meaningful error
- Requests without a JWT token return `401`
- Requesting a deleted employee returns `404`
- The salary endpoint writes to `salary_histories`
- The list endpoint paginates and filters correctly

### 5. Serializers — `test/serializers/`

Serializer tests are used to verify that the response shape matches the API contract — the right fields are present, sensitive fields aren't leaked, and decimal values are serialised as strings rather than floats.

---

### 5. Rake tasks — `test/tasks/`

One-off data tasks (such as the salary history backfill) get their own test class. These tests invoke the task directly via `Rake::Task`, assert on database state before and after, and verify idempotency by re-enabling and re-invoking the task.

---

## What makes a good test here

A test is doing its job if it fails when behaviour breaks and passes when it works — and if the failure message makes the cause obvious without having to read the implementation. Test names are written as plain descriptions of behaviour, not implementation details.

```ruby
# Good
test "excludes soft-deleted employees from salary insights" do ...

# Less useful
test "deleted_at scope works" do ...
```

Each test sets up only what it needs. A test for salary averaging doesn't need an employee with a department or hire date — only salary, country, and whatever the filter requires. Lean fixtures per test make failures easier to understand.
