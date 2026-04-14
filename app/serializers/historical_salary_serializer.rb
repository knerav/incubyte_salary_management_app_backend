class HistoricalSalarySerializer
  def initialize(result, filters, group_by: "month")
    @result   = result
    @filters  = filters
    @group_by = group_by
  end

  def as_json
    {
      filters:  @filters,
      group_by: @group_by,
      series:   serialize_series
    }
  end

  private

  def serialize_series
    @result.series.map do |entry|
      {
        period:         entry[:period],
        avg_salary:     "%.2f" % entry[:avg_salary],
        employee_count: entry[:employee_count]
      }
    end
  end
end
