class DepartmentsController < ApplicationController
  before_action :set_department, only: %i[edit update destroy]

  def index
    @departments = Department.order(:name)
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.turbo_stream
        format.html { redirect_to departments_path, notice: "Department was successfully created." }
      else
        format.turbo_stream { render :new, status: :unprocessable_content }
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def edit; end

  def update
    if @department.update(department_params)
      redirect_to departments_path, notice: "Department was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @department.destroy

    if @department.destroyed?
      redirect_to departments_path, notice: "Department was successfully deleted."
    else
      @departments = Department.order(:name)
      render :index, status: :unprocessable_content
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
