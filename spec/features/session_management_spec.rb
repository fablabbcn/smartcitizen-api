require "rails_helper"

feature "User logs in" do

  let(:password) { "password123" }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  scenario "user logs in with email" do
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content("You have been successfully logged in!")
  end

  scenario "user logs in, with goto url" do
    # This tests logins initiated from the legacy angular app.
    visit "/ui/sessions/new?goto=https%3A%2F%2Fsmartcitizen.me%2F"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
    expect(page).to have_current_path("https://smartcitizen.me/")
  end

  scenario "user logs in with username" do
    visit "/login"
    fill_in "Username or email", with: user.username
    fill_in "Password", with: password
    click_button "Log in"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content("You have been successfully logged in!")
  end

  scenario "user logs in with erroneous password" do
    visit "/login"
    fill_in "Username or email", with: user.username
    fill_in "Password", with: "notarealpassword"
    click_button "Log in"
    expect(page).to have_current_path(ui_sessions_path)
    expect(page).to have_content("Email or password is invalid")
  end

  scenario "user logs in with erroneous username" do
    visit "/login"
    fill_in "Username or email", with: "notarealusername"
    fill_in "Password", with: password
    click_button "Log in"
    expect(page).to have_current_path(ui_sessions_path)
    expect(page).to have_content("Email or password is invalid")
  end

  scenario "user logs out" do
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
    click_on "Log out", match: :first
    expect(page).to have_current_path(new_ui_session_path)
    expect(page).to have_content("Logged out!")
  end

  scenario "user signs out directly, with goto url" do
    # This tests logouts initiated from the legacy angular app.
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
    visit "/ui/sessions/destroy?goto=https%3A%2F%2Fsmartcitizen.me%2F"
    expect(page).to have_current_path("https://smartcitizen.me")
    visit "/ui"
    expect(page).to have_current_path(new_ui_session_path)
  end

  scenario "user resets email" do
    visit "/login"
    fill_in "Username or email", with: user.email
    click_on "Reset password"
    expect(page).to have_content("Please check your email to reset the password")
    visit "/password_reset/#{user.reload.password_reset_token}"
    fill_in "Password", with: "newpassword456"
    fill_in "Confirm new password", with: "newpassword456"
    click_on "Change my password"
    expect(page).to have_content("Changed password for: #{user.username}")
    fill_in "Username or email", with: user.username
    fill_in "Password", with: "newpassword456"
    click_button "Log in"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content("You have been successfully logged in!")
  end

  scenario "user resets email but gives incorrect password confirmation" do
    visit "/login"
    fill_in "Username or email", with: user.email
    click_on "Reset password"
    expect(page).to have_content("Please check your email to reset the password")
    visit "/password_reset/#{user.reload.password_reset_token}"
    fill_in "Password", with: "newpassword456"
    fill_in "Confirm new password", with: "password456"
    click_on "Change my password"
    expect(page).to have_current_path(ui_change_password_path)
    expect(page).to have_content("Your password doesn't match the confirmation")
  end

  scenario "user attempts to reset password with an erroneous token" do
    visit "/password_reset/notarealtoken"
    fill_in "Password", with: "newpassword456"
    fill_in "Confirm new password", with: "newpassword456"
    click_on "Change my password"
    expect(page).to have_current_path(ui_change_password_path)
    expect(page).to have_content("Your reset code might be too old or have been used before.")
  end

  scenario "discourse_login_flow" do
    secret = DiscourseController::DISCOURSE_SSO_SECRET
    nonce = "12345"
    return_sso_url = "https://discourse.example.com"
    unencrypted_payload = "nonce=#{nonce}&return_sso_url=#{return_sso_url}"
    payload = Base64.encode64(unencrypted_payload)
    signature = OpenSSL::HMAC.hexdigest("sha256", secret, payload)
    visit "/discourse/sso?sso=#{CGI.escape(payload)}&sig=#{signature}"
    expect(page).to have_current_path(new_ui_session_path + "?goto=%2Fdiscourse%2Fsso")
    expect(page).to have_content("Please log in before using SSO")
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    begin
      click_button "Log in"
    # The next doesn't exist, we just want to check the URL is correct:
    rescue ActionController::RoutingError
      expect(page.current_url).to match(/^#{DiscourseController::DISCOURSE_ENDPOINT}/)
      uri = URI.parse(page.current_url)
      params = CGI.parse(uri.query)
      check_signature = OpenSSL::HMAC.hexdigest("sha256", secret, params["sso"][0])
      expect(params["sig"][0]).to eq(check_signature)
      payload = CGI.parse(Base64.decode64(CGI.unescape(params["sso"][0])))
      expect(payload["nonce"][0]).to eq(nonce)
      expect(payload["username"][0]).to eq(user.email)
      expect(payload["email"][0]).to eq(user.email)
      expect(payload["external_id"][0]).to eq(user.id.to_s)
      expect(payload["return_sso_url"][0]).to eq(return_sso_url)
    end
  end
end
