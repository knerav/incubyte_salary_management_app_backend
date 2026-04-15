class Api::V1::DepartmentsController < Api::V1::BaseController
  def index
    render json: { departments: Department.order(:name).select(:id, :name) }
  end
end
