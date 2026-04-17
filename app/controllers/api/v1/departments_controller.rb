class Api::V1::DepartmentsController < Api::V1::BaseController
  before_action :set_department, only: %i[update destroy]

  def index
    render json: { departments: Department.order(:name).select(:id, :name) }
  end

  def create
    department = Department.new(department_params)
    if department.save
      render json: department.slice(:id, :name), status: :created
    else
      render_errors(department)
    end
  end

  def update
    if @department.update(department_params)
      render json: @department.slice(:id, :name)
    else
      render_errors(@department)
    end
  end

  def destroy
    @department.destroy
    if @department.destroyed?
      head :no_content
    else
      render_errors(@department)
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
