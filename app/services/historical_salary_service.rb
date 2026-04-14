class HistoricalSalaryService
  Result = Struct.new(:series)

  def initialize(filters, from: nil, to: nil, group_by: "month")
    @filters  = filters
    @from     = from ? from.to_date : 12.months.ago.to_date
    @to       = to   ? to.to_date   : Date.today
    @group_by = group_by
  end

  def call
    employee_scope = EmployeeFilterService.new(@filters).call

    period_sql = case @group_by
                 when "quarter"
                   "TO_CHAR(effective_from, 'YYYY') || '-Q' || TO_CHAR(effective_from, 'Q')"
                 when "year"
                   "TO_CHAR(effective_from, 'YYYY')"
                 else
                   "TO_CHAR(effective_from, 'YYYY-MM')"
                 end

    rows = SalaryHistory
      .where(employee: employee_scope)
      .where(effective_from: @from..@to)
      .group(Arel.sql(period_sql))
      .order(Arel.sql(period_sql))
      .pluck(
        Arel.sql(period_sql),
        Arel.sql("AVG(salary)"),
        Arel.sql("COUNT(DISTINCT employee_id)")
      )

    series = rows.map do |period, avg, count|
      { period: period, avg_salary: avg&.to_f, employee_count: count }
    end

    Result.new(series)
  end
end
