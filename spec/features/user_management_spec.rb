require "rails_helper"

feature "User signs up for an account" do
  scenario "User signs up for an account with correct details" do
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user@example.com"
    fill_in "Username", with: "myusername"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    check "I accept the terms and conditions"
    click_on "Sign up"
    expect(page).to have_content("Thanks for signing up! You are now logged in.")
    expect(User.count).to eq(user_count_before + 1)
  end

  scenario "User uses invalid email" do
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user_example.com"
    fill_in "Username", with: "myusername"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    check "I accept the terms and conditions"
    click_on "Sign up"
    expect(page).to have_current_path(ui_users_path)
    expect(page).to have_content("Some errors prevented us from creating your account. Please check below and try again!")
    expect(page).to have_content("Email\nis invalid")
    expect(User.count).to eq(user_count_before)
  end

  scenario "User uses email that has already been taken" do
    FactoryBot.create(:user, email: "user@example.com")
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user@example.com"
    fill_in "Username", with: "myusername"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    check "I accept the terms and conditions"
    click_on "Sign up"
    expect(page).to have_current_path(ui_users_path)
    expect(page).to have_content("Some errors prevented us from creating your account. Please check below and try again!")
    expect(page).to have_content("Email\nhas already been taken")
    expect(User.count).to eq(user_count_before)
  end

  scenario "User uses invalid username" do
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user@example.com"
    fill_in "Username", with: "my@usernameisnotanemail.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    check "I accept the terms and conditions"
    click_on "Sign up"
    expect(page).to have_current_path(ui_users_path)
    expect(page).to have_content("Some errors prevented us from creating your account. Please check below and try again!")
    expect(page).to have_content("Username\nis invalid")
    expect(User.count).to eq(user_count_before)
  end

  scenario "User uses username that has already been taken" do
    FactoryBot.create(:user, username: "myusername")
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user@example.com"
    fill_in "Username", with: "myusername"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    check "I accept the terms and conditions"
    click_on "Sign up"
    expect(page).to have_current_path(ui_users_path)
    expect(page).to have_content("Some errors prevented us from creating your account. Please check below and try again!")
    expect(page).to have_content("Username\nhas already been taken")
    expect(User.count).to eq(user_count_before)
  end

  scenario "User provides passwords that dont match" do
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user@example.com"
    fill_in "Username", with: "myusername"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password246"
    check "I accept the terms and conditions"
    click_on "Sign up"
    expect(page).to have_current_path(ui_users_path)
    expect(page).to have_content("Some errors prevented us from creating your account. Please check below and try again!")
    expect(page).to have_content("Password confirmation\ndoesn't match Password")
    expect(User.count).to eq(user_count_before)
  end

  scenario "User does not confirm terms and conditions" do
    user_count_before = User.count
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Email", with: "user@example.com"
    fill_in "Username", with: "myusername"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_on "Sign up"
    expect(page).to have_current_path(ui_users_path)
    expect(page).to have_content("Some errors prevented us from creating your account. Please check below and try again!")
    expect(page).to have_css("#user_ts_and_cs.is-invalid")
    expect(User.count).to eq(user_count_before)
  end

  scenario "User deletes their account" do
    password = "password123"
    username = "username"
    user = create(:user, username: username, password: password, password_confirmation: password)
    devices = 2.times.map { create(:device, owner: user) }
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    click_on "Edit your profile"
    click_on "Permanently delete your account"
    expect(page).to have_current_path(delete_ui_user_path(user.username))
    fill_in "To confirm, type your username below:", with: username
    click_on "I understand, delete my account"
    expect(page).to have_current_path(post_delete_ui_users_path)
    expect(page).to have_content("We are sorry to see you go!")
    expect(user.reload).to be_archived
    devices.each do |device|
      expect(device.reload).to be_archived
    end
  end

  scenario "User views their own profile" do
    password = "password123"
    username = "username"
    user = create(:user, username: username, password: password, password_confirmation: password)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content(user.username)
  end

  scenario "User edits their own profile" do
    password = "password123"
    username = "username"
    user = create(:user, username: username, password: password, password_confirmation: password)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    click_on "Edit your profile"
    fill_in "Username", with: "my_new_name"
    fill_in "Website", with: "https://example.com"
    click_on "Update"
    expect(page).to have_current_path(ui_user_path(user.reload.username))
    expect(page).to have_content("my_new_name")
    expect(page).to have_content("https://example.com")
    expect(page).to have_content("Your profile has been updated!")
  end

  scenario "User views their secrets" do
    password = "password123"
    username = "username"
    user = create(:user, username: username, password: password, password_confirmation: password)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    click_on "Show your API keys"
    expect(page).to have_current_path(secrets_ui_user_path(user.username))
    expect(page).to have_content(user.access_token.token)
  end
end
