require "test_helper"

module Api
  module V1
    class JobTitlesTest < ActionDispatch::IntegrationTest
      # — Index ————————————————————————————————————————————————————————————

      test "index returns 200 with a job_titles array" do
        token = api_sign_in(users(:hr_manager))
        get api_v1_job_titles_url, headers: { Authorization: token }, as: :json
        assert_response :ok
        assert response.parsed_body.key?("job_titles")
      end

      test "index returns 401 without a token" do
        get api_v1_job_titles_url, as: :json
        assert_response :unauthorized
      end

      # — Create ————————————————————————————————————————————————————————————

      test "create returns 201 with the new job title" do
        token = api_sign_in(users(:hr_manager))
        post api_v1_job_titles_url,
          params: { job_title: { name: "Staff Engineer" } },
          headers: { Authorization: token },
          as: :json
        assert_response :created
        assert_equal "Staff Engineer", response.parsed_body["name"]
        assert response.parsed_body.key?("id")
      end

      test "create returns 401 without a token" do
        post api_v1_job_titles_url,
          params: { job_title: { name: "Staff Engineer" } },
          as: :json
        assert_response :unauthorized
      end

      test "create returns 422 when name is blank" do
        token = api_sign_in(users(:hr_manager))
        post api_v1_job_titles_url,
          params: { job_title: { name: "" } },
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
        assert response.parsed_body.key?("errors")
      end

      test "create returns 422 when name is already taken" do
        token = api_sign_in(users(:hr_manager))
        post api_v1_job_titles_url,
          params: { job_title: { name: job_titles(:software_engineer).name } },
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
      end

      # — Update ————————————————————————————————————————————————————————————

      test "update returns 200 with the updated job title" do
        token = api_sign_in(users(:hr_manager))
        patch api_v1_job_title_url(job_titles(:qa_engineer)),
          params: { job_title: { name: "QA Lead" } },
          headers: { Authorization: token },
          as: :json
        assert_response :ok
        assert_equal "QA Lead", response.parsed_body["name"]
      end

      test "update returns 401 without a token" do
        patch api_v1_job_title_url(job_titles(:qa_engineer)),
          params: { job_title: { name: "QA Lead" } },
          as: :json
        assert_response :unauthorized
      end

      test "update returns 404 for a non-existent job title" do
        token = api_sign_in(users(:hr_manager))
        patch api_v1_job_title_url(id: 0),
          params: { job_title: { name: "Ghost" } },
          headers: { Authorization: token },
          as: :json
        assert_response :not_found
      end

      test "update returns 422 when name is already taken" do
        token = api_sign_in(users(:hr_manager))
        patch api_v1_job_title_url(job_titles(:qa_engineer)),
          params: { job_title: { name: job_titles(:software_engineer).name } },
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
      end

      # — Destroy ————————————————————————————————————————————————————————————

      test "destroy returns 204 when no active employees are assigned" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_job_title_url(job_titles(:qa_engineer)),
          headers: { Authorization: token },
          as: :json
        assert_response :no_content
      end

      test "destroy returns 401 without a token" do
        delete api_v1_job_title_url(job_titles(:qa_engineer)), as: :json
        assert_response :unauthorized
      end

      test "destroy returns 404 for a non-existent job title" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_job_title_url(id: 0),
          headers: { Authorization: token },
          as: :json
        assert_response :not_found
      end

      test "destroy returns 422 when active employees are assigned" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_job_title_url(job_titles(:software_engineer)),
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
        assert response.parsed_body.key?("errors")
      end

      test "destroy succeeds when the only assigned employee is soft-deleted" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_job_title_url(job_titles(:designer)),
          headers: { Authorization: token },
          as: :json
        assert_response :no_content
      end
    end
  end
end
