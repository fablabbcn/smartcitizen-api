require "rails_helper"

feature "Device management" do
  scenario "User views a device" do
    password = "password123"
    username = "username"
    device_name = "devicename"
    user = create(:user, username: username, password: password, password_confirmation: password)
    device = create(:device, name: device_name, owner: user)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content(device_name)
    click_on device_name
    expect(page).to have_current_path(ui_device_path(device.id))
    expect(page).to have_content(device_name)
  end
end
