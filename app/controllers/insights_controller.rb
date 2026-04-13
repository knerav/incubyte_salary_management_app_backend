class InsightsController < ApplicationController
  def index
    @filters = filter_params

    scope = Employee.all
    scope = scope.where(country: @filters[:country])           if @filters[:country].present?
    scope = scope.where(department: @filters[:department])     if @filters[:department].present?
    scope = scope.where(job_title_id: @filters[:job_title_id]) if @filters[:job_title_id].present?

    @stats = scope.pick(
      Arel.sql("COUNT(*)"),
      Arel.sql("MIN(salary)"),
      Arel.sql("MAX(salary)"),
      Arel.sql("AVG(salary)")
    )

    @employee_count = @stats[0].to_i
    @min_salary     = @stats[1]&.to_f
    @max_salary     = @stats[2]&.to_f
    @avg_salary     = @stats[3]&.to_f

    @breakdowns = scope
      .joins(:job_title)
      .group("job_titles.name")
      .average(:salary)
      .transform_values(&:to_f)
      .sort_by { |_, v| -v }
  end

  private

  def filter_params
    params.permit(:country, :department, :job_title_id)
  end
end
