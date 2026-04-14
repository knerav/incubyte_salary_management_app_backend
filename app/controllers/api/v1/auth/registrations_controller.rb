class Api::V1::Auth::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { message: "Signed up successfully." }, status: :created
    else
      render json: { errors: resource.errors.as_json }, status: :unprocessable_content
    end
  end
end
