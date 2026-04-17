class Api::V1::CountriesController < Api::V1::BaseController
  def index
    codes = Employee.distinct.pluck(:country).compact
    countries = codes.map do |code|
      country = ISO3166::Country.new(code)
      { code: code, name: country&.iso_short_name || code }
    end.sort_by { |c| c[:name] }
    render json: { countries: countries }
  end
end
