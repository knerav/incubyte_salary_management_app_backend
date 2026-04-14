class SalaryInsightsService
  Result = Struct.new(:employee_count, :min_salary, :max_salary, :avg_salary, :breakdowns)

  def initialize(scope)
    @scope = scope
  end

  def call
    stats = @scope.pick(
      Arel.sql("COUNT(*)"),
      Arel.sql("MIN(salary)"),
      Arel.sql("MAX(salary)"),
      Arel.sql("AVG(salary)")
    )

    breakdowns = @scope
      .joins(:job_title)
      .group("job_titles.name")
      .average(:salary)
      .transform_values(&:to_f)
      .sort_by { |_, v| -v }
      .to_h

    Result.new(
      stats[0].to_i,
      stats[1]&.to_f,
      stats[2]&.to_f,
      stats[3]&.to_f,
      breakdowns
    )
  end
end
