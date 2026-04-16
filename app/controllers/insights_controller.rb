class InsightsController < ApplicationController
  def index
    @filters         = filter_params
    scope            = EmployeeFilterService.new(@filters).call
    @insights        = SalaryInsightsService.new(scope).call
    @currency_symbol = CurrencyLookup.symbol_for(@filters[:country])
    @countries       = ISO3166::Country.all.sort_by(&:iso_short_name)
  end

  private

  def filter_params
    permitted          = params.permit(:country, :department_id, :job_title_id)
    permitted[:country] ||= CurrencyLookup::DEFAULT_COUNTRY
    permitted
  end
end
