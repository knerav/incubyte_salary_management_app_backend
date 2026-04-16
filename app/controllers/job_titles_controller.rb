class JobTitlesController < ApplicationController
  before_action :set_job_title, only: %i[show edit update destroy]

  def index
    @job_titles = JobTitle.order(:name)
  end

  def show; end

  def new
    @job_title = JobTitle.new
  end

  def create
    @job_title = JobTitle.new(job_title_params)

    respond_to do |format|
      if @job_title.save
        format.turbo_stream
        format.html { redirect_to job_titles_path, notice: "Job title was successfully created." }
      else
        format.turbo_stream { render :new, status: :unprocessable_content }
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @job_title.update(job_title_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@job_title, partial: "job_titles/job_title", locals: { job_title: @job_title }) }
        format.html { redirect_to job_titles_path, notice: "Job title was successfully updated." }
      else
        format.turbo_stream { render :edit, status: :unprocessable_content }
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @job_title.destroy

    respond_to do |format|
      if @job_title.destroyed?
        format.turbo_stream
        format.html { redirect_to job_titles_path, notice: "Job title was successfully deleted." }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash",
            partial: "shared/alert",
            locals: { message: @job_title.errors.full_messages.to_sentence })
        }
        format.html { redirect_to job_titles_path, alert: @job_title.errors.full_messages.to_sentence }
      end
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
