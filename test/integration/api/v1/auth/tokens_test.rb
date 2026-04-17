require "test_helper"

module Api
  module V1
    module Auth
      class TokensTest < ActionDispatch::IntegrationTest
        private

        def sign_in_and_capture_refresh_token
          api_sign_in(users(:hr_manager))
          response.parsed_body.dig("auth", "refresh_token")
        end

        public
        # — Guard ————————————————————————————————————————————————————————————

        test "returns 401 without a refresh token in the body" do
          post "/api/v1/users/refresh", as: :json
          assert_response :unauthorized
        end

        test "returns 401 with an unrecognised refresh token" do
          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: "not-a-real-token" } },
            as: :json
          assert_response :unauthorized
        end

        test "returns 401 with an expired refresh token" do
          raw_token = sign_in_and_capture_refresh_token
          RefreshToken.last.update_columns(expires_at: 1.day.ago)

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json
          assert_response :unauthorized
        end

        # — Happy path ———————————————————————————————————————————————————————

        test "returns 200 with a valid refresh token in the body" do
          raw_token = sign_in_and_capture_refresh_token

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json
          assert_response :ok
        end

        test "response body confirms the token was refreshed" do
          raw_token = sign_in_and_capture_refresh_token

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json
          assert_equal "Token refreshed successfully.", response.parsed_body["message"]
        end

        test "returns a new JWT in the Authorization response header" do
          old_jwt = api_sign_in(users(:hr_manager))
          raw_token = response.parsed_body.dig("auth", "refresh_token")

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json

          new_jwt = response.headers["Authorization"]
          assert_not_nil new_jwt
          assert new_jwt.start_with?("Bearer ")
          assert_not_equal old_jwt, new_jwt
        end

        test "returns a new refresh token in the response body" do
          old_raw = sign_in_and_capture_refresh_token

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: old_raw } },
            as: :json

          new_raw = response.parsed_body.dig("auth", "refresh_token")
          assert_not_nil new_raw
          assert_not_equal old_raw, new_raw
        end

        test "new JWT grants access to protected endpoints" do
          raw_token = sign_in_and_capture_refresh_token

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json

          get api_v1_employees_url,
            headers: { Authorization: response.headers["Authorization"] },
            as: :json
          assert_response :ok
        end

        # — Rotation —————————————————————————————————————————————————————————

        test "old refresh token is invalidated after use" do
          old_raw = sign_in_and_capture_refresh_token

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: old_raw } },
            as: :json

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: old_raw } },
            as: :json
          assert_response :unauthorized
        end

        test "refresh replaces the RefreshToken record" do
          raw_token = sign_in_and_capture_refresh_token
          old_id = RefreshToken.last.id

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json

          assert_nil RefreshToken.find_by(id: old_id)
          assert_not_nil RefreshToken.last
          assert_not_equal old_id, RefreshToken.last.id
        end
      end
    end
  end
end
