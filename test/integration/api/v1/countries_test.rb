require "test_helper"

module Api
  module V1
    class CountriesTest < ActionDispatch::IntegrationTest
      test "returns 200" do
        token = api_sign_in(users(:hr_manager))
        get api_v1_countries_url, headers: { Authorization: token }, as: :json
        assert_response :ok
      end

      test "returns 401 without a token" do
        get api_v1_countries_url, as: :json
        assert_response :unauthorized
      end

      test "response contains a countries array" do
        token = api_sign_in(users(:hr_manager))
        get api_v1_countries_url, headers: { Authorization: token }, as: :json
        assert response.parsed_body.key?("countries")
      end

      test "each entry has a code and name" do
        token = api_sign_in(users(:hr_manager))
        get api_v1_countries_url, headers: { Authorization: token }, as: :json
        country = response.parsed_body["countries"].first
        assert country.key?("code")
        assert country.key?("name")
      end

      test "only returns countries with active employees" do
        # Fixtures: john_doe (US), jane_smith (IN), deleted_employee (GB - soft deleted)
        token = api_sign_in(users(:hr_manager))
        get api_v1_countries_url, headers: { Authorization: token }, as: :json
        codes = response.parsed_body["countries"].map { |c| c["code"] }
        assert_includes codes, "US"
        assert_includes codes, "IN"
        assert_not_includes codes, "GB"
      end

      test "countries are sorted alphabetically by name" do
        token = api_sign_in(users(:hr_manager))
        get api_v1_countries_url, headers: { Authorization: token }, as: :json
        names = response.parsed_body["countries"].map { |c| c["name"] }
        assert_equal names.sort, names
      end
    end
  end
end
