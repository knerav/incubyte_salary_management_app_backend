class ApiFailureApp < Devise::FailureApp
  def respond
    if request.path.start_with?("/api/")
      json_error
    else
      super
    end
  end

  private

  def json_error
    self.status = 401
    self.content_type = "application/json"
    self.response_body = { error: "Unauthorized" }.to_json
  end
end
