class Api::V1::Insights::SalaryController < Api::V1::BaseController
  def index
    scope    = EmployeeFilterService.new(filter_params).call
    insights = SalaryInsightsService.new(scope).call
    render json: SalaryInsightsSerializer.new(insights, filter_params).as_json
  end

  private

  def filter_params
    permitted = params.permit(:country, :department_id, :job_title_id)
    permitted[:country] ||= CurrencyLookup::DEFAULT_COUNTRY
    permitted
  end
end
