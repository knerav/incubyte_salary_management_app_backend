require "test_helper"

module Api
  module V1
    module Auth
      class SessionsTest < ActionDispatch::IntegrationTest
        private

        def refresh_token_set_cookie
          Array(response.headers["Set-Cookie"]).find { |c| c.start_with?("refresh_token=") }
        end

        public
        # — Sign in ——————————————————————————————————————————————————————————

        test "sign in sets a refresh_token cookie" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          assert_not_nil cookies[:refresh_token]
        end

        test "sign in creates a RefreshToken record" do
          assert_difference "RefreshToken.count", 1 do
            post "/api/v1/users/sign_in",
              params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
              as: :json
          end
        end

        test "sign in cookie is HttpOnly" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          cookie = refresh_token_set_cookie
          assert_match(/HttpOnly/i, cookie)
        end

        test "sign in cookie is scoped to the refresh path" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          assert_match(%r{path=/api/v1/users/refresh}i, refresh_token_set_cookie)
        end

        test "sign in cookie expires in 7 days" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "Password1!" } },
            as: :json

          assert_match(/max-age=604800/i, refresh_token_set_cookie)
        end

        test "failed sign in does not set a refresh_token cookie" do
          post "/api/v1/users/sign_in",
            params: { user: { email: users(:hr_manager).email, password: "wrong" } },
            as: :json

          assert_nil cookies[:refresh_token]
        end

        # — Sign out —————————————————————————————————————————————————————————

        test "sign out clears the refresh_token cookie" do
          jwt = api_sign_in(users(:hr_manager))

          delete "/api/v1/users/sign_out",
            headers: { Authorization: jwt, Cookie: "refresh_token=#{cookies[:refresh_token]}" },
            as: :json

          assert_match(/max-age=0/i, response.headers["Set-Cookie"])
        end

        test "sign out deletes the RefreshToken record" do
          jwt = api_sign_in(users(:hr_manager))

          assert_difference "RefreshToken.count", -1 do
            delete "/api/v1/users/sign_out",
              headers: { Authorization: jwt, Cookie: "refresh_token=#{cookies[:refresh_token]}" },
              as: :json
          end
        end

        test "sign out with no refresh token cookie still succeeds" do
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
