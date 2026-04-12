# Testing Strategy

The assignment asks for tests that are fast, deterministic, and easy to understand. Those three constraints directly informed every choice I made here.

I'm following a strict TDD cycle — red, green, refactor — throughout the Rails codebase. I chose an inside-out approach: model tests first, then services, then integration tests for the API layer. Outside-in TDD (starting from integration tests and working inward) makes more sense when requirements are still being discovered. Here, the requirements were already thoroughly worked through during event storming and captured in the data model and API contract, so inside-in lets me move faster with tighter, more focused test cycles.

Even infrastructure concerns like migrations follow the TDD cycle. Rather than writing migrations speculatively upfront, each migration is driven by a failing test — the test failure is the red state that makes the migration necessary.

---

## Framework and test data

I'm using Minitest — the Rails default — with no additional testing frameworks. I manage test data with Rails fixtures (YAML) rather than FactoryBot. Fixtures load once per suite rather than building records on every test, which keeps the suite fast. They're also explicit — the test data is exactly what it says it is in the file, with no factory traits or sequences to mentally unpack.

---

## What I'm testing and in what order

### 1. Models — `test/models/`

I start here. Model tests cover validations, associations, and scopes — anything that enforces data integrity or shapes how records are queried.

I pay particular attention to the soft delete default scope. If it regresses, deleted employees silently reappear in every query and every insight calculation. A dedicated test that verifies deleted records are excluded by default is essential.

### 2. Controllers — `test/controllers/`

With the models in place, I move to controllers for the standard CRUD actions. Testing controllers at this stage naturally drives the emergence of Hotwire views — each controller action that needs to render a response pushes the view into existence. The views start basic and get refined later.

### 3. Services — `test/services/`

This is where I put my most meaningful tests. The service objects encapsulate the core business logic — salary aggregations, historical trend queries, and employee filtering. I test these directly rather than through the API, which keeps them fast and makes failures easy to diagnose.

Specific cases I cover:

- `SalaryInsightsService` returns correct min, max, and average for a given filter combination
- `HistoricalSalaryService` groups salary data correctly by month, quarter, and year
- `EmployeeFilterService` applies multiple filters additively and respects the soft delete scope
- Edge cases: a country or department with a single employee, a date range with no salary history records

### 4. Integration tests — `test/integration/`

Integration tests come last and exercise the full API stack — through the router, controller, service, and serializer — asserting on status codes and response shapes. I don't re-test the business logic here (that's covered by service tests), but I verify the plumbing: routing, parameter handling, error responses, and the JSON structure the frontend depends on.

Key cases I cover per endpoint:

- Happy path returns the expected status code and response shape
- Missing or invalid parameters return a `422` with a meaningful error
- Requesting a deleted employee returns `404`
- The salary endpoint writes to `salary_histories`
- The list endpoint paginates and filters correctly

### 5. Serializers — `test/serializers/`

I use serializer tests to verify that the response shape matches the API contract — the right fields are present, sensitive fields aren't leaked, and decimal values are serialised as strings rather than floats.

---

## What I'm not testing

I don't test Rails internals. That `validates_presence_of` works, that `belongs_to` sets up the association, or that ActiveRecord can write to the database — these are framework guarantees, not application logic.

I also don't cover the Hotwire views with automated tests. The HTML rendering is exercised manually during development, and the underlying logic is already covered by model and service tests.

---

## What makes a good test here

A test is doing its job if it fails when behaviour breaks and passes when it works — and if the failure message makes the cause obvious without having to read the implementation. I write test names as plain descriptions of behaviour, not implementation details.

```ruby
# Good
test "excludes soft-deleted employees from salary insights" do ...

# Less useful
test "deleted_at scope works" do ...
```

Each test sets up only what it needs. A test for salary averaging doesn't need an employee with a department or hire date — only salary, country, and whatever the filter requires. Lean fixtures per test make failures easier to understand.
