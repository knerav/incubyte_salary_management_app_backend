class EmployeeSerializer
  def initialize(employee)
    @employee = employee
  end

  def as_json
    {
      id:              @employee.id,
      first_name:      @employee.first_name,
      last_name:       @employee.last_name,
      email:           @employee.email,
      job_title:       @employee.job_title.name,
      department:      @employee.department.name,
      country:         @employee.country,
      salary:          @employee.salary.to_s,
      currency:        @employee.currency,
      employment_type: @employee.employment_type,
      hired_on:        @employee.hired_on.iso8601
    }
  end
end
