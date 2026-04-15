class Api::V1::JobTitlesController < Api::V1::BaseController
  def index
    render json: { job_titles: JobTitle.order(:name).select(:id, :name) }
  end
end
