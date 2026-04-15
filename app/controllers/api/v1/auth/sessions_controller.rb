class Api::V1::Auth::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: { message: "Signed in successfully." }, status: :ok
  end

  def respond_to_on_destroy
    render json: { message: "Signed out successfully." }, status: :ok
  end
end
