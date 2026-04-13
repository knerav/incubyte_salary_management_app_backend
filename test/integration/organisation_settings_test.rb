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

  test "includes a link to job titles" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_select "a[href='#{job_titles_path}']"
  end

  test "includes a link to departments" do
    sign_in_as users(:hr_manager)
    get organisation_settings_url
    assert_select "a[href='#{departments_path}']"
  end
end
