require "test_helper"

module Api
  module V1
    module Auth
      class TokensTest < ActionDispatch::IntegrationTest
        # — Authentication guard —————————————————————————————————————————————

        test "returns 401 without a token" do
          post "/api/v1/users/refresh", as: :json
          assert_response :unauthorized
        end

        test "returns 401 with an invalid token" do
          post "/api/v1/users/refresh",
            headers: { Authorization: "Bearer not.a.real.token" },
            as: :json
          assert_response :unauthorized
        end

        # — Happy path ———————————————————————————————————————————————————————

        test "returns 200 with a valid token" do
          token = api_sign_in(users(:hr_manager))
          post "/api/v1/users/refresh", headers: { Authorization: token }, as: :json
          assert_response :ok
        end

        test "returns a new JWT in the Authorization response header" do
          old_token = api_sign_in(users(:hr_manager))
          post "/api/v1/users/refresh", headers: { Authorization: old_token }, as: :json
          new_token = response.headers["Authorization"]
          assert_not_nil new_token
          assert new_token.start_with?("Bearer ")
          assert_not_equal old_token, new_token
        end

        test "response body confirms the token was refreshed" do
          token = api_sign_in(users(:hr_manager))
          post "/api/v1/users/refresh", headers: { Authorization: token }, as: :json
          assert_equal "Token refreshed successfully.", response.parsed_body["message"]
        end

        test "new token grants access to protected endpoints" do
          old_token = api_sign_in(users(:hr_manager))
          post "/api/v1/users/refresh", headers: { Authorization: old_token }, as: :json
          new_token = response.headers["Authorization"]

          get api_v1_employees_url, headers: { Authorization: new_token }, as: :json
          assert_response :ok
        end

        # — Token rotation ———————————————————————————————————————————————————

        test "old token is revoked after refresh" do
          old_token = api_sign_in(users(:hr_manager))
          post "/api/v1/users/refresh", headers: { Authorization: old_token }, as: :json

          # reset! clears the Warden session cookie so the next request authenticates
          # via JWT alone — the same conditions a real API client faces.
          reset!

          get api_v1_employees_url, headers: { Authorization: old_token }, as: :json
          assert_response :unauthorized
        end
      end
    end
  end
end
