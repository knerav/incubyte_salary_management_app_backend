require "test_helper"

module Api
  module V1
    module Auth
      class SessionsTest < ActionDispatch::IntegrationTest
        # — Sign in ——————————————————————————————————————————————————————————

        test "sign in returns 200" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          assert_response :ok
        end

        test "sign in returns a JWT in the Authorization response header" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          assert response.headers["Authorization"].start_with?("Bearer ")
        end

        test "sign in returns the refresh token in the response body" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          assert_not_nil response.parsed_body.dig("auth", "refresh_token")
        end

        test "sign in creates a RefreshToken record" do
          assert_difference "RefreshToken.count", 1 do
            post "/api/v1/users/sign_in",
              params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
              as: :json
          end
        end

        test "failed sign in does not return a refresh token" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "wrong" } },
            as: :json

          assert_nil response.parsed_body.dig("auth", "refresh_token")
        end

        # — Sign out —————————————————————————————————————————————————————————

        test "sign out returns 200" do
          jwt = api_sign_in(users(:hr_manager))

          delete "/api/v1/users/sign_out",
            headers: { Authorization: jwt },
            as: :json

          assert_response :ok
        end

        test "sign out with refresh token in body deletes the RefreshToken record" do
          jwt = api_sign_in(users(:hr_manager))
          raw_token = response.parsed_body.dig("auth", "refresh_token")

          assert_difference "RefreshToken.count", -1 do
            delete "/api/v1/users/sign_out",
              params: { auth: { refresh_token: raw_token } },
              headers: { Authorization: jwt },
              as: :json
          end
        end

        test "sign out without refresh token in body still succeeds" do
          jwt = api_sign_in(users(:hr_manager))

          delete "/api/v1/users/sign_out",
            headers: { Authorization: jwt },
            as: :json

          assert_response :ok
        end
      end
    end
  end
end
