class Api::V1::Auth::TokensController < Api::V1::BaseController
  def create
    current_user.update!(jti: SecureRandom.uuid)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(current_user, :user, nil)
    response.set_header("Authorization", "Bearer #{token}")
    render json: { message: "Token refreshed successfully." }, status: :ok
  end
end
