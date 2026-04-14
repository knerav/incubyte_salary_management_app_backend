class EmployeeFilterService
  def initialize(filters)
    @filters = filters
  end

  def call
    scope = Employee.all
    scope = scope.where(country: @filters[:country])               if @filters[:country].present?
    scope = scope.where(department_id: @filters[:department_id])   if @filters[:department_id].present?
    scope = scope.where(job_title_id: @filters[:job_title_id])     if @filters[:job_title_id].present?
    scope = scope.where(employment_type: @filters[:employment_type]) if @filters[:employment_type].present?
    scope = scope.where(
      "LOWER(first_name || ' ' || last_name) LIKE ?",
      "%#{@filters[:q].downcase}%"
    ) if @filters[:q].present?
    scope
  end
end
