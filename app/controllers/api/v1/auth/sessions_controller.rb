class Api::V1::Auth::SessionsController < Devise::SessionsController
  skip_before_action :require_no_authentication
  skip_before_action :verify_authenticity_token

  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource, store: false)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  private

  def respond_with(resource, _opts = {})
    raw_token = RefreshToken.generate_for(resource)
    render json: { message: "Signed in successfully.", auth: { refresh_token: raw_token } }, status: :ok
  end

  def respond_to_on_destroy(**_opts)
    if (raw = params.dig(:auth, :refresh_token))
      RefreshToken.find_active_by_token(raw)&.destroy
    end
    render json: { message: "Signed out successfully." }, status: :ok
  end
end
