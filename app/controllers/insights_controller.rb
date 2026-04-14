class InsightsController < ApplicationController
  def index
    @filters = filter_params
    scope    = EmployeeFilterService.new(@filters).call
    @insights = SalaryInsightsService.new(scope).call
  end

  private

  def filter_params
    params.permit(:country, :department_id, :job_title_id)
  end
end
