class Api::V1::Auth::TokensController < ActionController::API
  def create
    raw = params.dig(:auth, :refresh_token)
    record = raw && RefreshToken.find_active_by_token(raw)

    unless record
      render json: { error: "Invalid or expired refresh token." }, status: :unauthorized
      return
    end

    user = record.user
    record.destroy
    new_raw = RefreshToken.generate_for(user)

    user.update!(jti: SecureRandom.uuid)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

    response.set_header("Authorization", "Bearer #{token}")
    render json: { message: "Token refreshed successfully.", auth: { refresh_token: new_raw } }, status: :ok
  end
end
