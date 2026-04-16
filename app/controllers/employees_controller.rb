class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show edit update salary destroy]

  def index
    @pagy, @employees = pagy(:offset, Employee.includes(:job_title, :department).order(:last_name, :first_name))
  end

  def show; end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.turbo_stream
        format.html { redirect_to employee_path(@employee), notice: "Employee was successfully created." }
      else
        format.turbo_stream { render :new, status: :unprocessable_content }
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.turbo_stream
        format.html { redirect_to employee_path(@employee), notice: "Employee was successfully updated." }
      else
        format.turbo_stream { render :edit, status: :unprocessable_content }
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def salary
    if @employee.update(salary_params)
      redirect_to employee_path(@employee), notice: "Salary was successfully updated."
    else
      render :show, status: :unprocessable_content
    end
  end

  def destroy
    @employee.update_column(:deleted_at, Time.current)
    redirect_to employees_path, notice: "Employee was successfully deleted."
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render file: "public/404.html", status: :not_found, layout: false
  end

  def employee_params
    params.require(:employee).permit(
      :first_name, :last_name, :email, :job_title_id, :department_id,
      :country, :salary, :currency, :employment_type, :hired_on
    )
  end

  def salary_params
    params.require(:employee).permit(:salary, :currency)
  end
end
