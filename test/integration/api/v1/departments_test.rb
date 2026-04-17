require "test_helper"

module Api
  module V1
    class DepartmentsTest < ActionDispatch::IntegrationTest
      # — Index ————————————————————————————————————————————————————————————

      test "index returns 200 with a departments array" do
        token = api_sign_in(users(:hr_manager))
        get api_v1_departments_url, headers: { Authorization: token }, as: :json
        assert_response :ok
        assert response.parsed_body.key?("departments")
      end

      test "index returns 401 without a token" do
        get api_v1_departments_url, as: :json
        assert_response :unauthorized
      end

      # — Create ————————————————————————————————————————————————————————————

      test "create returns 201 with the new department" do
        token = api_sign_in(users(:hr_manager))
        post api_v1_departments_url,
          params: { department: { name: "Finance" } },
          headers: { Authorization: token },
          as: :json
        assert_response :created
        assert_equal "Finance", response.parsed_body["name"]
        assert response.parsed_body.key?("id")
      end

      test "create returns 401 without a token" do
        post api_v1_departments_url,
          params: { department: { name: "Finance" } },
          as: :json
        assert_response :unauthorized
      end

      test "create returns 422 when name is blank" do
        token = api_sign_in(users(:hr_manager))
        post api_v1_departments_url,
          params: { department: { name: "" } },
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
        assert response.parsed_body.key?("errors")
      end

      test "create returns 422 when name is already taken" do
        token = api_sign_in(users(:hr_manager))
        post api_v1_departments_url,
          params: { department: { name: departments(:engineering).name } },
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
      end

      # — Update ————————————————————————————————————————————————————————————

      test "update returns 200 with the updated department" do
        token = api_sign_in(users(:hr_manager))
        patch api_v1_department_url(departments(:qa)),
          params: { department: { name: "Quality Assurance" } },
          headers: { Authorization: token },
          as: :json
        assert_response :ok
        assert_equal "Quality Assurance", response.parsed_body["name"]
      end

      test "update returns 401 without a token" do
        patch api_v1_department_url(departments(:qa)),
          params: { department: { name: "Quality Assurance" } },
          as: :json
        assert_response :unauthorized
      end

      test "update returns 404 for a non-existent department" do
        token = api_sign_in(users(:hr_manager))
        patch api_v1_department_url(id: 0),
          params: { department: { name: "Ghost" } },
          headers: { Authorization: token },
          as: :json
        assert_response :not_found
      end

      test "update returns 422 when name is already taken" do
        token = api_sign_in(users(:hr_manager))
        patch api_v1_department_url(departments(:qa)),
          params: { department: { name: departments(:engineering).name } },
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
      end

      # — Destroy ————————————————————————————————————————————————————————————

      test "destroy returns 204 when no active employees are assigned" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_department_url(departments(:qa)),
          headers: { Authorization: token },
          as: :json
        assert_response :no_content
      end

      test "destroy returns 401 without a token" do
        delete api_v1_department_url(departments(:qa)), as: :json
        assert_response :unauthorized
      end

      test "destroy returns 404 for a non-existent department" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_department_url(id: 0),
          headers: { Authorization: token },
          as: :json
        assert_response :not_found
      end

      test "destroy returns 422 when active employees are assigned" do
        token = api_sign_in(users(:hr_manager))
        delete api_v1_department_url(departments(:engineering)),
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
        assert response.parsed_body.key?("errors")
      end

      test "destroy returns 422 when the only assigned employee is soft-deleted" do
        # Soft-deleted employees still hold the foreign key — deleting the department
        # would leave a dangling reference if the employee were ever restored.
        token = api_sign_in(users(:hr_manager))
        delete api_v1_department_url(departments(:design)),
          headers: { Authorization: token },
          as: :json
        assert_response :unprocessable_content
      end
    end
  end
end
