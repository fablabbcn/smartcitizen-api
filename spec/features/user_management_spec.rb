require "rails_helper"

feature "User signs up for an account" do
  scenario "User signs up for an account with correct details" do
    visit "/login"
    click_on "Sign up"
    expect(page).to have_current_path(new_ui_user_path)
    fill_in "Username", with: "myusername"
    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    check "I have read and accept the Terms and Conditions"
    click_on "Sign up"
    expect(page).to have_content("Thanks for signing up! You are now logged in.")
  end
end
