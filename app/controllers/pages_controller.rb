class PagesController < ApplicationController
  def organisation_settings
    @job_titles = JobTitle.order(:name)
    @departments = Department.order(:name)
  end
end
