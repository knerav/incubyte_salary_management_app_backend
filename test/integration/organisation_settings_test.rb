require "test_helper"

class OrganisationSettingsTest < ActionDispatch::IntegrationTest
  # — Authentication guard —————————————————————————————————————————————————

  test "redirects unauthenticated users to sign in" do
    get organisation_settings_url
    assert_redirected_to new_user_session_url
  end

  # — Index ————————————————————————————————————————————————————————————————

  test "renders the organisation settings page for authenticated users" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_response :ok
  end

  test "renders the job titles list inline" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_select "turbo-frame#job_titles_list"
  end

  test "renders the departments list inline" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_select "turbo-frame#departments_list"
  end

  test "displays existing job titles on the page" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_select "turbo-frame#job_titles_list", text: /#{job_titles(:software_engineer).name}/
  end

  test "displays existing departments on the page" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_select "turbo-frame#departments_list", text: /#{departments(:engineering).name}/
  end
end
