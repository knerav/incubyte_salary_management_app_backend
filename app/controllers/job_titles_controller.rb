class JobTitlesController < ApplicationController
  before_action :set_job_title, only: %i[edit update destroy]

  def index
    @job_titles = JobTitle.order(:name)
  end

  def new
    @job_title = JobTitle.new
  end

  def create
    @job_title = JobTitle.new(job_title_params)

    if @job_title.save
      redirect_to job_titles_path, notice: "Job title was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @job_title.update(job_title_params)
      redirect_to job_titles_path, notice: "Job title was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @job_title.destroy

    if @job_title.destroyed?
      redirect_to job_titles_path, notice: "Job title was successfully deleted."
    else
      render :index, status: :unprocessable_content
    end
  end

  private

  def set_job_title
    @job_title = JobTitle.find(params[:id])
  end

  def job_title_params
    params.require(:job_title).permit(:name)
  end
end
