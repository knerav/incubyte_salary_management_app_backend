module RefreshTokenCookie
  private

  def set_refresh_token_cookie(raw_token)
    cookies[:refresh_token] = {
      value: raw_token,
      http_only: true,
      secure: Rails.env.production?,
      same_site: :strict,
      path: "/api/v1/users/refresh",
      max_age: RefreshToken::EXPIRY.to_i
    }
  end

  def clear_refresh_token_cookie
    cookies[:refresh_token] = {
      value: "",
      http_only: true,
      secure: Rails.env.production?,
      same_site: :strict,
      path: "/api/v1/users/refresh",
      max_age: 0
    }
  end
end
