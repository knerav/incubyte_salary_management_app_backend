# API Contract

All endpoints are prefixed with `/api/v1`. Both frontends are served from the same controllers via `respond_to` — JSON for the Next.js frontend, HTML for the Hotwire frontend. This document covers the JSON contract only.

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
| `department`      | string  | Filter by department           |
| `job_title`       | string  | Filter by job title            |
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
{ "error": "Employee not found" }
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
  "job_title": "Software Engineer",
  "department": "Engineering",
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
  "currency": "USD",
  "effective_from": "2025-04-01"
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

## Insights

### Current salary insights

```
GET /api/v1/insights/salary
```

I require at least one filter parameter — returning aggregates over all 10,000 employees with no filter is valid but not useful to an HR manager.

**Query parameters:**

| Parameter    | Type   | Description          |
| ------------ | ------ | -------------------- |
| `country`    | string | Filter by country    |
| `department` | string | Filter by department |
| `job_title`  | string | Filter by job title  |

Filters are additive — multiple parameters narrow the result set.

**Response `200`:**

```json
{
  "filters": {
    "country": "US",
    "department": "Engineering"
  },
  "insights": {
    "min_salary": "60000.00",
    "max_salary": "210000.00",
    "avg_salary": "118500.00",
    "employee_count": 430
  }
}
```

**Response `422`:**

```json
{ "error": "At least one filter parameter is required" }
```

---

### Historical salary insights

```
GET /api/v1/insights/salary/history
```

This endpoint is backed by `salary_histories` and supports the same filter dimensions as current insights, with an additional date range and grouping period for time-series visualisation.

**Query parameters:**

| Parameter    | Type   | Description                                           |
| ------------ | ------ | ----------------------------------------------------- |
| `country`    | string | Filter by country                                     |
| `department` | string | Filter by department                                  |
| `job_title`  | string | Filter by job title                                   |
| `from`       | date   | Start of date range, default 12 months ago            |
| `to`         | date   | End of date range, default today                      |
| `group_by`   | string | Grouping period: `month` (default), `quarter`, `year` |

**Response `200`:**

```json
{
  "filters": {
    "country": "US",
    "department": "Engineering"
  },
  "group_by": "month",
  "series": [
    { "period": "2024-01", "avg_salary": "115000.00", "employee_count": 418 },
    { "period": "2024-02", "avg_salary": "116200.00", "employee_count": 421 },
    { "period": "2024-03", "avg_salary": "117800.00", "employee_count": 428 }
  ]
}
```
