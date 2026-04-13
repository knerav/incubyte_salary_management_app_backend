class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show edit update salary destroy]

  def index
    @employees = Employee.includes(:job_title).order(:last_name, :first_name)
  end

  def show; end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)

    if @employee.save
      redirect_to employee_path(@employee), notice: "Employee was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @employee.update(employee_params)
      redirect_to employee_path(@employee), notice: "Employee was successfully updated."
    else
      render :edit, status: :unprocessable_content
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
      :first_name, :last_name, :email, :job_title_id,
      :department, :country, :salary, :currency, :employment_type, :hired_on
    )
  end

  def salary_params
    params.require(:employee).permit(:salary, :currency)
  end
end
