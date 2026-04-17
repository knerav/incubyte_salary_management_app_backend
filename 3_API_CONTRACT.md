# API Contract

All endpoints are prefixed with `/api/v1`. Both frontends are served from the same controllers via `respond_to` — JSON for the Next.js frontend, HTML for the Hotwire frontend. This document covers the JSON contract only.

---

## Authentication

All API endpoints except sign-in, sign-up, and token refresh require a JWT Bearer token in the `Authorization` header:

```
Authorization: Bearer <token>
```

Requests without a valid token return `401 Unauthorized`.

### Sign in

```
POST /api/v1/users/sign_in
```

**Request body:**

```json
{ "user": { "email": "hr@company.com", "password": "Password1!" } }
```

**Response `200`:**
- `Authorization` response header contains the JWT. Tokens expire after 30 minutes.
- Response body contains the refresh token in an `auth` hash:

```json
{
  "message": "Signed in successfully.",
  "auth": {
    "refresh_token": "<raw_token>"
  }
}
```

The client is responsible for storing the refresh token and including it in subsequent refresh requests.

### Refresh token

```
POST /api/v1/users/refresh
```

No `Authorization` header is required. This endpoint does not require a valid JWT — it exists specifically to obtain one after the previous token has expired.

**Request body:**

```json
{
  "auth": {
    "refresh_token": "<raw_token>"
  }
}
```

**Response `200`:**
- `Authorization` response header contains a new JWT.
- Response body contains the rotated refresh token:

```json
{
  "message": "Token refreshed successfully.",
  "auth": {
    "refresh_token": "<new_raw_token>"
  }
}
```

The old refresh token is immediately invalidated.

**Response `401`:** Refresh token is missing, not found, or expired. The client should clear local state and redirect to sign-in.

### Sign out

```
DELETE /api/v1/users/sign_out
```

Revokes the current JWT via the JTIMatcher strategy. Optionally accepts the refresh token in the request body to invalidate it at the same time — if omitted, the refresh token record is left in place but the JWT is still revoked.

**Request body (optional):**

```json
{
  "auth": {
    "refresh_token": "<raw_token>"
  }
}
```

**Response `200`:** `{ "message": "Signed out successfully." }`

### Sign up

```
POST /api/v1/users
```

**Request body:**

```json
{ "user": { "email": "hr@company.com", "password": "Password1!", "password_confirmation": "Password1!" } }
```

**Response `201`:** `{ "message": "Signed up successfully." }`

> In ordinary circumstances I would not pair a React frontend with a Rails monolith (as the Hotwire stack covers that need without introducing a separate frontend). I've opted for this combination specifically for the scope of this assignment to demonstrate that I'm comfortable working with both a Rails monolith and an isolated frontend/backend architecture.

> I'm using a flat JSON format rather than the JSON:API specification. In a larger system with multiple resources and complex relationships, I would reach for the `jsonapi-serializer` gem — it enforces a consistent envelope, handles relationships cleanly, and scales well across a large API surface. For this scope, the added verbosity isn't justified.

---

## Employees

### List employees

```
GET /api/v1/employees
```

**Query parameters:**

| Parameter         | Type    | Description                    |
| ----------------- | ------- | ------------------------------ |
| `page`            | integer | Page number, default `1`       |
| `per_page`        | integer | Records per page, default `25` |
| `q`               | string  | Search by name                 |
| `country`         | string  | Filter by country              |
| `department_id`   | integer | Filter by department           |
| `job_title_id`    | integer | Filter by job title            |
| `employment_type` | string  | Filter by employment type      |

**Response `200`:**

```json
{
  "employees": [
    {
      "id": 1,
      "first_name": "Jane",
      "last_name": "Smith",
      "email": "jane.smith@company.com",
      "job_title": "Software Engineer",
      "department": "Engineering",
      "country": "US",
      "salary": "95000.00",
      "currency": "USD",
      "employment_type": "full_time",
      "hired_on": "2022-03-14"
    }
  ],
  "meta": {
    "total": 10000,
    "page": 1,
    "per_page": 25,
    "total_pages": 400
  }
}
```

---

### Get employee

```
GET /api/v1/employees/:id
```

**Response `200`:**

```json
{
  "id": 1,
  "first_name": "Jane",
  "last_name": "Smith",
  "email": "jane.smith@company.com",
  "job_title": "Software Engineer",
  "department": "Engineering",
  "country": "US",
  "salary": "95000.00",
  "currency": "USD",
  "employment_type": "full_time",
  "hired_on": "2022-03-14"
}
```

**Response `404`:**

```json
{ "error": "Not found" }
```

---

### Create employee

```
POST /api/v1/employees
```

**Request body:**

```json
{
  "first_name": "Jane",
  "last_name": "Smith",
  "email": "jane.smith@company.com",
  "job_title_id": 1,
  "department_id": 2,
  "country": "US",
  "salary": "95000.00",
  "currency": "USD",
  "employment_type": "full_time",
  "hired_on": "2022-03-14"
}
```

**Response `201`:** Created employee object (same shape as Get employee).

**Response `422`:**

```json
{
  "errors": {
    "email": ["has already been taken"],
    "salary": ["must be greater than 0"]
  }
}
```

---

### Update employee

```
PATCH /api/v1/employees/:id
```

**Request body:** Any subset of employee fields, excluding `salary` and `currency` — I route salary changes through the dedicated salary endpoint to ensure history is always recorded.

**Response `200`:** Updated employee object.

**Response `422`:** Validation errors (same shape as Create).

---

### Update salary

```
PATCH /api/v1/employees/:id/salary
```

I use a dedicated endpoint for salary changes so that writing to `salary_histories` is structural rather than procedural — it can't be bypassed by accident.

**Request body:**

```json
{
  "salary": "105000.00",
  "currency": "USD"
}
```

**Response `200`:** Updated employee object.

**Response `422`:** Validation errors.

---

### Delete employee

```
DELETE /api/v1/employees/:id
```

Employees are soft deleted by setting `deleted_at`, retaining the record for historical insight calculations.

**Response `204`:** No content.

**Response `404`:** Employee not found.

---

### Get salary history

```
GET /api/v1/employees/:id/salary_history
```

Returns the full salary history for an individual employee, ordered chronologically. This is a separate endpoint rather than a nested field on the employee object — the employee list and show views don't need history, so separating it avoids loading it on every request.

**Response `200`:**

```json
{
  "salary_history": [
    {
      "effective_from": "2022-03-14",
      "salary": "95000.00",
      "currency": "USD",
      "change": null
    },
    {
      "effective_from": "2023-01-01",
      "salary": "105000.00",
      "currency": "USD",
      "change": "+10.53%"
    }
  ]
}
```

`change` is the percentage change from the preceding entry. The first entry is always `null`.

**Response `404`:** Employee not found.

---

## Reference data

### List job titles

```
GET /api/v1/job_titles
```

**Response `200`:**

```json
{
  "job_titles": [
    { "id": 1, "name": "Software Engineer" },
    { "id": 2, "name": "Product Manager" }
  ]
}
```

---

### Create job title

```
POST /api/v1/job_titles
```

**Request body:**

```json
{ "job_title": { "name": "Staff Engineer" } }
```

**Response `201`:** `{ "id": 3, "name": "Staff Engineer" }`

**Response `422`:** `{ "errors": { "name": ["has already been taken"] } }`

---

### Update job title

```
PATCH /api/v1/job_titles/:id
```

**Request body:**

```json
{ "job_title": { "name": "Principal Engineer" } }
```

**Response `200`:** `{ "id": 3, "name": "Principal Engineer" }`

**Response `404`:** `{ "error": "Not found" }`

**Response `422`:** Validation errors (same shape as Create).

---

### Delete job title

```
DELETE /api/v1/job_titles/:id
```

Deletion is blocked if any active employees are assigned to this job title.

**Response `204`:** No content.

**Response `404`:** `{ "error": "Not found" }`

**Response `422`:** `{ "errors": { "base": ["Cannot delete job title with assigned employees"] } }`

---

### List departments

```
GET /api/v1/departments
```

**Response `200`:**

```json
{
  "departments": [
    { "id": 1, "name": "Engineering" },
    { "id": 2, "name": "Product" }
  ]
}
```

---

### Create department

```
POST /api/v1/departments
```

**Request body:**

```json
{ "department": { "name": "Design" } }
```

**Response `201`:** `{ "id": 3, "name": "Design" }`

**Response `422`:** `{ "errors": { "name": ["has already been taken"] } }`

---

### Update department

```
PATCH /api/v1/departments/:id
```

**Request body:**

```json
{ "department": { "name": "Product Design" } }
```

**Response `200`:** `{ "id": 3, "name": "Product Design" }`

**Response `404`:** `{ "error": "Not found" }`

**Response `422`:** Validation errors (same shape as Create).

---

### Delete department

```
DELETE /api/v1/departments/:id
```

Deletion is blocked if any active employees are assigned to this department.

**Response `204`:** No content.

**Response `404`:** `{ "error": "Not found" }`

**Response `422`:** `{ "errors": { "base": ["Cannot delete department with assigned employees"] } }`

---

### List countries

```
GET /api/v1/countries
```

Returns only countries that have at least one active employee — not the full ISO list. Use this to populate the country filter dropdown on the insights and employee list pages.

**Response `200`:**

```json
{
  "countries": [
    { "code": "GB", "name": "United Kingdom" },
    { "code": "US", "name": "United States" }
  ]
}
```

`code` is the ISO 3166-1 alpha-2 country code (the value to send as the `country` query parameter). `name` is the full display name, sorted alphabetically.

---

## Insights

### Current salary insights

```
GET /api/v1/insights/salary
```

**Query parameters:**

| Parameter    | Type   | Description          |
| ------------ | ------ | -------------------- |
| `country`       | string  | Filter by country    |
| `department_id` | integer | Filter by department |
| `job_title_id`  | integer | Filter by job title  |

Filters are additive — multiple parameters narrow the result set.

**Response `200`:**

```json
{
  "filters": {
    "country": "US",
    "department_id": "2"
  },
  "insights": {
    "employee_count": 430,
    "min_salary": "60000.00",
    "max_salary": "210000.00",
    "avg_salary": "118500.00",
    "currency_code": "USD",
    "currency_symbol": "$",
    "breakdowns": [
      { "job_title": "Staff Engineer", "avg_salary": "175000.00" },
      { "job_title": "Senior Engineer", "avg_salary": "140000.00" }
    ]
  }
}
```

`currency_code` and `currency_symbol` are derived from the `country` filter (defaulting to `IN`/`INR`/`₹` when no country is selected). The frontend can use these directly to format salary values without its own currency lookup.

