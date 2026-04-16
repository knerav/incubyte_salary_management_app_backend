class PagesController < ApplicationController
  def home
  end

  def organisation_settings
    @job_titles = JobTitle.order(:name)
    @departments = Department.order(:name)
  end
end
