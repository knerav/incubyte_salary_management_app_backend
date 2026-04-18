class Api::V1::Auth::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      sign_in(resource_name, resource, store: false)
      raw_token = RefreshToken.generate_for(resource)
      render json: { message: "Signed up successfully.", auth: { refresh_token: raw_token } }, status: :created
    else
      render json: { errors: resource.errors.as_json }, status: :unprocessable_content
    end
  end
end
