class Api::V1::EmployeesController < Api::V1::BaseController
  before_action :set_employee, only: %i[show update salary destroy]

  def index
    scope      = EmployeeFilterService.new(filter_params).call
    total      = scope.count
    page       = (params[:page] || 1).to_i
    per_page   = (params[:per_page] || 25).to_i
    employees  = scope.includes(:job_title, :department)
                      .order(:last_name, :first_name)
                      .offset((page - 1) * per_page)
                      .limit(per_page)

    render json: {
      employees: employees.map { |e| EmployeeSerializer.new(e).as_json },
      meta: {
        total:       total,
        page:        page,
        per_page:    per_page,
        total_pages: (total.to_f / per_page).ceil
      }
    }
  end

  def show
    render json: EmployeeSerializer.new(@employee).as_json
  end

  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: EmployeeSerializer.new(employee).as_json, status: :created
    else
      render_errors(employee)
    end
  end

  def update
    if @employee.update(employee_params)
      render json: EmployeeSerializer.new(@employee).as_json
    else
      render_errors(@employee)
    end
  end

  def salary
    if @employee.update(salary_params)
      render json: EmployeeSerializer.new(@employee).as_json
    else
      render_errors(@employee)
    end
  end

  def destroy
    @employee.update_column(:deleted_at, Time.current)
    head :no_content
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def employee_params
    params.permit(
      :first_name, :last_name, :email, :job_title_id, :department_id,
      :country, :salary, :currency, :employment_type, :hired_on
    )
  end

  def salary_params
    params.permit(:salary, :currency)
  end

  def filter_params
    params.permit(:country, :department_id, :job_title_id, :employment_type, :q)
  end
end
