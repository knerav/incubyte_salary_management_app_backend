class Api::V1::BaseController < ActionController::API
  before_action :authenticate_user!

  respond_to :json

  private

  def render_not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def render_errors(resource)
    render json: { errors: resource.errors.as_json }, status: :unprocessable_content
  end
end
