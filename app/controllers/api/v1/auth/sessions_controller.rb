class Api::V1::Auth::SessionsController < Devise::SessionsController
  include RefreshTokenCookie

  skip_before_action :verify_authenticity_token

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    raw_token = RefreshToken.generate_for(resource)
    set_refresh_token_cookie(raw_token)
    render json: { message: "Signed in successfully." }, status: :ok
  end

  def respond_to_on_destroy(**_opts)
    if (raw = cookies[:refresh_token])
      RefreshToken.find_active_by_token(raw)&.destroy
    end
    clear_refresh_token_cookie
    render json: { message: "Signed out successfully." }, status: :ok
  end
end
