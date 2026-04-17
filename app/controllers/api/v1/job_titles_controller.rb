class Api::V1::JobTitlesController < Api::V1::BaseController
  before_action :set_job_title, only: %i[update destroy]

  def index
    render json: { job_titles: JobTitle.order(:name).select(:id, :name) }
  end

  def create
    job_title = JobTitle.new(job_title_params)
    if job_title.save
      render json: job_title.slice(:id, :name), status: :created
    else
      render_errors(job_title)
    end
  end

  def update
    if @job_title.update(job_title_params)
      render json: @job_title.slice(:id, :name)
    else
      render_errors(@job_title)
    end
  end

  def destroy
    @job_title.destroy
    if @job_title.destroyed?
      head :no_content
    else
      render_errors(@job_title)
    end
  end

  private

  def set_job_title
    @job_title = JobTitle.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def job_title_params
    params.require(:job_title).permit(:name)
  end
end
