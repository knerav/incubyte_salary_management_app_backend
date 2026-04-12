In this document, I'd like share how I translate business requirements into the broad design of the system. I like following a mix of BDUF (Big design up front), and event storming to give an initial "shape" to the project. This approach has always helped me talk through business requirements and translate them to specs effectively, especially with a physical audience.

To recap my understanding of the system at hand, it's is a salary management tool for an organisation with 10,000 employees. The sole user persona is an **HR Manager** who needs to manage employee records and derive salary insights across countries and job titles.

---

### Domain Events

**Employee domain:**

- `EmployeeAdded`
- `EmployeeUpdated`
- `EmployeeSalaryUpdated`
- `EmployeeDeleted`
- `EmployeeProfileViewed`
- `EmployeeListViewed`
- `EmployeeListFiltered`

**Insights domain:**

- `SalaryInsightsViewed`
- `HistoricalSalaryInsightsViewed`

**System:**

- `SalaryHistoryRecorded`
- `EmployeeDataSeeded`

> Please note: I separated `EmployeeSalaryUpdated` from `EmployeeUpdated` deliberately as I feel that salary changes carry more business significance than other field updates.

---

### Event Timeline

```
[EmployeeDataSeeded]
        │
        ▼
[EmployeeAdded] ──► [EmployeeListViewed] ──► [EmployeeProfileViewed]
        │                    │
        ▼                    ▼
[EmployeeUpdated]    [EmployeeListFiltered] ──► [SalaryInsightsViewed]
[EmployeeDeleted]                               [HistoricalSalaryInsightsViewed]

[EmployeeSalaryUpdated] ──► [SalaryHistoryRecorded]
```

The domain fits within a single bounded context. `SalaryHistoryRecorded` is fired automatically as a side effect of `EmployeeSalaryUpdated` (most likely through a callback).

---

### Commands

| Command                        | Triggers Event                   | Actor            |
| ------------------------------ | -------------------------------- | ---------------- |
| `AddEmployee`                  | `EmployeeAdded`                  | _HR Manager_     |
| `UpdateEmployee`               | `EmployeeUpdated`                | _HR Manager_     |
| `UpdateSalary`                 | `EmployeeSalaryUpdated`          | _HR Manager_     |
| `DeleteEmployee`               | `EmployeeDeleted`                | _HR Manager_     |
| `ViewEmployee`                 | `EmployeeProfileViewed`          | _HR Manager_     |
| `ListEmployees`                | `EmployeeListViewed`             | _HR Manager_     |
| `FilterEmployees`              | `EmployeeListFiltered`           | _HR Manager_     |
| `ViewSalaryInsights`           | `SalaryInsightsViewed`           | _HR Manager_     |
| `ViewHistoricalSalaryInsights` | `HistoricalSalaryInsightsViewed` | _HR Manager_     |
| `RunSeedScript`                | `EmployeeDataSeeded`             | _Engineer / CLI_ |

With only one user-facing actor, I didn't need to introduce any role-based access control for the scope of this assignment.

---

### Aggregates & Read Models

**Aggregate: Employee**

The only mutable domain object. It handles all write commands and is the source of truth for all employee state.

Owns:

- Identity (name, email)
- Employment details (job title, department, country, employment type, hire date)
- Compensation (salary, currency)

**Read Model: SalaryInsights**

Not a mutable aggregate — derived on demand from `Employee` data via SQL aggregations, with no separate data store. Everything is computed at query time.

Exposes:

- Minimum, maximum, and average salary by country
- Average salary by job title within a country
- Average salary by department within a country

**Append-only Log: SalaryHistory**

Not a mutable aggregate — each record is written once when a salary changes and never updated. It backs the `HistoricalSalaryInsights` read model, enabling time-series queries across all insight dimensions: country, department, and job title.
