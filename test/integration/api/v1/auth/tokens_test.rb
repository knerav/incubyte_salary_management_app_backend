require "test_helper"

module Api
  module V1
    module Auth
      class TokensTest < ActionDispatch::IntegrationTest
        # — Guard ————————————————————————————————————————————————————————————

        test "returns 401 without a refresh token cookie" do
          post "/api/v1/users/refresh", as: :json
          assert_response :unauthorized
        end

        test "returns 401 with an unrecognised refresh token" do
          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=not-a-real-token" },
            as: :json
          assert_response :unauthorized
        end

        test "returns 401 with an expired refresh token" do
          api_sign_in(users(:hr_manager))
          raw_cookie = cookies[:refresh_token]
          RefreshToken.last.update_columns(expires_at: 1.day.ago)

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{raw_cookie}" },
            as: :json
          assert_response :unauthorized
        end

        # — Happy path ———————————————————————————————————————————————————————

        test "returns 200 with a valid refresh token cookie" do
          api_sign_in(users(:hr_manager))

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json
          assert_response :ok
        end

        test "response body confirms the token was refreshed" do
          api_sign_in(users(:hr_manager))

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json
          assert_equal "Token refreshed successfully.", response.parsed_body["message"]
        end

        test "returns a new JWT in the Authorization response header" do
          old_jwt = api_sign_in(users(:hr_manager))

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json

          new_jwt = response.headers["Authorization"]
          assert_not_nil new_jwt
          assert new_jwt.start_with?("Bearer ")
          assert_not_equal old_jwt, new_jwt
        end

        test "new JWT grants access to protected endpoints" do
          api_sign_in(users(:hr_manager))

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json

          get api_v1_employees_url,
            headers: { Authorization: response.headers["Authorization"] },
            as: :json
          assert_response :ok
        end

        test "sets a new refresh_token cookie" do
          api_sign_in(users(:hr_manager))
          old_cookie = cookies[:refresh_token]

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{old_cookie}" },
            as: :json

          assert_not_nil cookies[:refresh_token]
          assert_not_equal old_cookie, cookies[:refresh_token]
        end

        test "new cookie is HttpOnly and scoped to the refresh path" do
          api_sign_in(users(:hr_manager))

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json

          set_cookie = response.headers["Set-Cookie"]
          assert_match(/HttpOnly/i, set_cookie)
          assert_match(%r{path=/api/v1/users/refresh}i, set_cookie)
        end

        # — Rotation —————————————————————————————————————————————————————————

        test "old refresh token is invalidated after use" do
          api_sign_in(users(:hr_manager))
          old_cookie = cookies[:refresh_token]

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{old_cookie}" },
            as: :json

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{old_cookie}" },
            as: :json
          assert_response :unauthorized
        end

        test "refresh replaces the RefreshToken record" do
          api_sign_in(users(:hr_manager))
          old_id = RefreshToken.last.id

          post "/api/v1/users/refresh",
            headers: { Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json

          assert_nil RefreshToken.find_by(id: old_id)
          assert_not_nil RefreshToken.last
          assert_not_equal old_id, RefreshToken.last.id
        end
      end
    end
  end
end
