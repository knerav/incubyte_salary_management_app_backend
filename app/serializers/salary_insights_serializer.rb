class SalaryInsightsSerializer
  def initialize(insights, filters)
    @insights = insights
    @filters  = filters
  end

  def as_json
    {
      filters: @filters,
      insights: {
        employee_count: @insights.employee_count,
        min_salary:     format_salary(@insights.min_salary),
        max_salary:     format_salary(@insights.max_salary),
        avg_salary:     format_salary(@insights.avg_salary),
        breakdowns:     serialize_breakdowns
      }
    }
  end

  private

  def format_salary(value)
    value ? "%.2f" % value : nil
  end

  def serialize_breakdowns
    @insights.breakdowns.map do |job_title, avg|
      { job_title: job_title, avg_salary: "%.2f" % avg }
    end
  end
end
