require "test_helper"

class JobTitlesTest < ActionDispatch::IntegrationTest
  # — Authentication guard —————————————————————————————————————————————————

  test "redirects unauthenticated users to sign in" do
    get job_titles_url
    assert_redirected_to new_user_session_url
  end

  # — Index ————————————————————————————————————————————————————————————————

  test "renders the job titles list for authenticated users" do
    sign_in_as users(:hr_manager)
    get job_titles_url
    assert_response :ok
  end

  # — New / Create —————————————————————————————————————————————————————————

  test "renders the new job title form" do
    sign_in_as users(:hr_manager)
    get new_job_title_url
    assert_response :ok
  end

  test "creates a job title with valid params and redirects" do
    sign_in_as users(:hr_manager)

    assert_difference "JobTitle.count", 1 do
      post job_titles_url, params: { job_title: { name: "Engineering Manager" } }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "creates a job title via turbo stream and returns stream response" do
    sign_in_as users(:hr_manager)

    assert_difference "JobTitle.count", 1 do
      post job_titles_url,
        params: { job_title: { name: "Engineering Manager" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "re-renders the new form with 422 when name is blank" do
    sign_in_as users(:hr_manager)

    assert_no_difference "JobTitle.count" do
      post job_titles_url, params: { job_title: { name: "" } }
    end

    assert_response :unprocessable_content
  end

  test "re-renders modal via turbo stream with 422 when name is blank" do
    sign_in_as users(:hr_manager)

    assert_no_difference "JobTitle.count" do
      post job_titles_url,
        params: { job_title: { name: "" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :unprocessable_content
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "re-renders the new form with 422 on a duplicate name" do
    sign_in_as users(:hr_manager)

    assert_no_difference "JobTitle.count" do
      post job_titles_url, params: { job_title: { name: job_titles(:software_engineer).name } }
    end

    assert_response :unprocessable_content
  end

  # — Edit / Update ————————————————————————————————————————————————————————

  test "renders the edit job title form" do
    sign_in_as users(:hr_manager)
    get edit_job_title_url(job_titles(:software_engineer))
    assert_response :ok
  end

  test "updates a job title with valid params and redirects" do
    sign_in_as users(:hr_manager)

    patch job_title_url(job_titles(:software_engineer)), params: { job_title: { name: "Software Developer" } }

    assert_response :redirect
    follow_redirect!
    assert_response :ok
    assert_equal "Software Developer", job_titles(:software_engineer).reload.name
  end

  test "re-renders the edit form with 422 when name is blank" do
    sign_in_as users(:hr_manager)

    patch job_title_url(job_titles(:software_engineer)), params: { job_title: { name: "" } }

    assert_response :unprocessable_content
  end

  # — Delete ———————————————————————————————————————————————————————————————

  test "deletes a job title with no assigned employees and redirects" do
    sign_in_as users(:hr_manager)

    assert_difference "JobTitle.count", -1 do
      delete job_title_url(job_titles(:qa_engineer))
    end

    assert_response :redirect
    follow_redirect!
    assert_response :ok
  end

  test "deletes a job title via turbo stream and removes the row" do
    sign_in_as users(:hr_manager)

    assert_difference "JobTitle.count", -1 do
      delete job_title_url(job_titles(:qa_engineer)),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "prevents deletion of a job title that has employees assigned" do
    sign_in_as users(:hr_manager)

    assert_no_difference "JobTitle.count" do
      delete job_title_url(job_titles(:software_engineer))
    end

    assert_response :redirect
  end

  test "shows an error via turbo stream when deleting a job title with assigned employees" do
    sign_in_as users(:hr_manager)

    assert_no_difference "JobTitle.count" do
      delete job_title_url(job_titles(:software_engineer)),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end
end
