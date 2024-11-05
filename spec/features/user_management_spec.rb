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
end
