require "test_helper"

module Api
  module V1
    module Insights
      class SalaryTest < ActionDispatch::IntegrationTest
  # — Authentication guard —————————————————————————————————————————————————

  test "returns 401 without a JWT token" do
    get api_v1_insights_salary_index_url, as: :json
    assert_response :unauthorized
  end

  # — Current insights —————————————————————————————————————————————————————

  test "returns salary insights" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, params: { country: "US" }, headers: { Authorization: token }, as: :json
    assert_response :ok
  end

  test "response includes filters and insights keys" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, params: { country: "US" }, headers: { Authorization: token }, as: :json
    body = response.parsed_body
    assert body.key?("filters")
    assert body.key?("insights")
  end

  test "insights include employee_count, min, max, avg salary and breakdowns" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, params: { country: "US" }, headers: { Authorization: token }, as: :json
    insights = response.parsed_body["insights"]
    %w[employee_count min_salary max_salary avg_salary breakdowns currency_code currency_symbol].each do |field|
      assert insights.key?(field), "expected insights to include #{field}"
    end
  end

  test "insights include currency_code for the requested country" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, params: { country: "IN" }, headers: { Authorization: token }, as: :json
    assert_equal "INR", response.parsed_body["insights"]["currency_code"]
  end

  test "insights include currency_symbol for the requested country" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, params: { country: "IN" }, headers: { Authorization: token }, as: :json
    symbol = response.parsed_body["insights"]["currency_symbol"]
    assert symbol.present?, "expected currency_symbol to be present"
  end

  test "defaults to India (IN) when no country param is given" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, headers: { Authorization: token }, as: :json
    assert_equal "IN", response.parsed_body["filters"]["country"]
  end

  test "defaults currency_code to INR when no country param is given" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, headers: { Authorization: token }, as: :json
    assert_equal "INR", response.parsed_body["insights"]["currency_code"]
  end

  test "filters insights by country" do
    token = api_sign_in(users(:hr_manager))
    get api_v1_insights_salary_index_url, params: { country: "US" }, headers: { Authorization: token }, as: :json
    assert_equal 1, response.parsed_body["insights"]["employee_count"]
  end

      end
    end
  end
end
