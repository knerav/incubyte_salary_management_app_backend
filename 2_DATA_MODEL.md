# Data Model

From the event storm, I identified two structures that need persistence: the `Employee` aggregate, which holds current state, and the `SalaryHistory` append-only log, which records salary changes over time to support historical insights.

---

### employees

| Column            | Type             | Constraints                                           |
| ----------------- | ---------------- | ----------------------------------------------------- |
| `id`              | `bigint`         | Primary key, auto-increment                           |
| `first_name`      | `varchar`        | NOT NULL                                              |
| `last_name`       | `varchar`        | NOT NULL                                              |
| `email`           | `varchar`        | NOT NULL, UNIQUE                                      |
| `job_title`       | `varchar`        | NOT NULL                                              |
| `department`      | `varchar`        | NOT NULL                                              |
| `country`         | `varchar`        | NOT NULL                                              |
| `salary`          | `decimal(15, 2)` | NOT NULL                                              |
| `currency`        | `varchar(3)`     | NOT NULL, default `'USD'`                             |
| `employment_type` | `varchar`        | NOT NULL — enum: `full_time`, `part_time`, `contract` |
| `hired_on`        | `date`           | NOT NULL                                              |
| `deleted_at`      | `timestamp`      | nullable                                              |
| `created_at`      | `timestamp`      | NOT NULL                                              |
| `updated_at`      | `timestamp`      | NOT NULL                                              |

---

### salary_histories

| Column           | Type             | Constraints                   |
| ---------------- | ---------------- | ----------------------------- |
| `id`             | `bigint`         | Primary key, auto-increment   |
| `employee_id`    | `bigint`         | NOT NULL, FK → `employees.id` |
| `salary`         | `decimal(15, 2)` | NOT NULL                      |
| `currency`       | `varchar(3)`     | NOT NULL                      |
| `effective_from` | `date`           | NOT NULL                      |
| `created_at`     | `timestamp`      | NOT NULL                      |

Each record is written once when a salary changes and never updated. `effective_from` is the date the new salary took effect, which lets me answer point-in-time queries like "what was the average salary in Germany in Q1?".

---

### Indexes

| Index                             | Columns                | Reason                                                                                 |
| --------------------------------- | ---------------------- | -------------------------------------------------------------------------------------- |
| Primary key                       | `id`                   | Row lookup                                                                             |
| Unique                            | `email`                | Uniqueness constraint                                                                  |
| `idx_employees_country`           | `country`              | Insights queries filter and group by country                                           |
| `idx_employees_job_title`         | `job_title`            | Insights queries filter and group by job title                                         |
| `idx_employees_department`        | `department`           | Insights queries filter and group by department                                        |
| `idx_employees_country_job_title` | `(country, job_title)` | Composite — covers the "avg salary for job title in country" query without a full scan |
| `idx_employees_deleted_at`        | `deleted_at`           | Soft delete — default scope filters `WHERE deleted_at IS NULL` on every query          |

**salary_histories indexes:**

| Index                                     | Columns                         | Reason                                                                   |
| ----------------------------------------- | ------------------------------- | ------------------------------------------------------------------------ |
| Primary key                               | `id`                            | Row lookup                                                               |
| `idx_salary_histories_employee_id`        | `employee_id`                   | FK lookup — fetch history for a given employee                           |
| `idx_salary_histories_effective_from`     | `effective_from`                | Time-series queries filter and group by date                             |
| `idx_salary_histories_employee_effective` | `(employee_id, effective_from)` | Composite — covers "latest salary for employee as of date X" efficiently |

---

### Notes

I store `first_name` and `last_name` separately rather than as a single `full_name`. The seed script generates names by combining values from `first_names.txt` and `last_names.txt`, so keeping them split avoids string manipulation at seed time and makes sorting by last name natural.

I use `decimal(15, 2)` for `salary` rather than `float`. Financial figures stored as floating point accumulate rounding errors in aggregate calculations — `decimal` gives exact representation.

I store `currency` alongside `salary` on every row. Salary without currency is ambiguous for a multi-country organisation, and keeping them together makes each record self-contained.

I constrain `employment_type` as an enum to `full_time`, `part_time`, and `contract`. This prevents data quality issues and makes it a reliable filter dimension for insights.

I use a nullable `deleted_at` timestamp rather than hard deleting employees. Permanently removing a row would silently distort historical insight calculations. The nullable timestamp retains the data while a Rails default scope excludes it from all queries automatically.

I considered separate `countries` and `job_titles` reference tables but left them out — both are free-text strings consistent enough for grouping without needing a lookup table at this scope.
