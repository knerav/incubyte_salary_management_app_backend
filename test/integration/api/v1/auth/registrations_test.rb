require "test_helper"

module Api
  module V1
    module Auth
      class RegistrationsTest < ActionDispatch::IntegrationTest
        VALID_PARAMS = {
          user: {
            email: "new_user@example.com",
            password: "Password1!",
            password_confirmation: "Password1!"
          }
        }.freeze

        # — Happy path ———————————————————————————————————————————————————————

        test "sign up returns 201" do
          post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          assert_response :created
        end

        test "sign up returns a JWT in the Authorization response header" do
          post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          assert response.headers["Authorization"].start_with?("Bearer ")
        end

        test "sign up returns the refresh token in the response body" do
          post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          assert_not_nil response.parsed_body.dig("auth", "refresh_token")
        end

        test "sign up creates a User record" do
          assert_difference "User.count", 1 do
            post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          end
        end

        test "sign up creates a RefreshToken record" do
          assert_difference "RefreshToken.count", 1 do
            post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          end
        end

        test "JWT from sign up grants access to protected endpoints" do
          post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          jwt = response.headers["Authorization"]

          get api_v1_employees_url, headers: { Authorization: jwt }, as: :json
          assert_response :ok
        end

        test "refresh token from sign up can be exchanged for a new JWT" do
          post "/api/v1/users/sign_up", params: VALID_PARAMS, as: :json
          raw_token = response.parsed_body.dig("auth", "refresh_token")

          post "/api/v1/users/refresh",
            params: { auth: { refresh_token: raw_token } },
            as: :json
          assert_response :ok
        end

        # — Validation failures ——————————————————————————————————————————————

        test "returns 422 with an already registered email" do
          post "/api/v1/users/sign_up",
            params: { user: { email: users(:hr_manager).email, password: "Password1!", password_confirmation: "Password1!" } },
            as: :json
          assert_response :unprocessable_entity
        end

        test "returns 422 with a missing password" do
          post "/api/v1/users/sign_up",
            params: { user: { email: "new_user@example.com", password: "", password_confirmation: "" } },
            as: :json
          assert_response :unprocessable_entity
        end

        test "returns 422 when password confirmation does not match" do
          post "/api/v1/users/sign_up",
            params: { user: { email: "new_user@example.com", password: "Password1!", password_confirmation: "Different1!" } },
            as: :json
          assert_response :unprocessable_entity
        end

        test "failed sign up does not create a User record" do
          assert_no_difference "User.count" do
            post "/api/v1/users/sign_up",
              params: { user: { email: "bad-email", password: "short", password_confirmation: "short" } },
              as: :json
          end
        end

        test "failed sign up does not return tokens" do
          post "/api/v1/users/sign_up",
            params: { user: { email: users(:hr_manager).email, password: "Password1!", password_confirmation: "Password1!" } },
            as: :json

          assert_nil response.parsed_body.dig("auth", "refresh_token")
          assert_nil response.headers["Authorization"]
        end

        test "failed sign up returns errors in the response body" do
          post "/api/v1/users/sign_up",
            params: { user: { email: users(:hr_manager).email, password: "Password1!", password_confirmation: "Password1!" } },
            as: :json

          assert_not_empty response.parsed_body["errors"]
        end
      end
    end
  end
end
