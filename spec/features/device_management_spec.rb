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

  scenario "User edits a device" do
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
    click_on "Edit kit settings"
    expect(page).to have_current_path(edit_ui_device_path(device.id))
    fill_in "Name", with: "new device name"
    click_on "Update"
    expect(page).to have_current_path(ui_device_path(device.id))
    expect(page).to have_content("new device name")
  end


  scenario "User deletes a device" do
    password = "password123"
    username = "username"
    device_name = "devicename"
    user = create(:user, username: username, password: password, password_confirmation: password)
    device = create(:device, name: device_name, owner: user)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    click_on device_name
    click_on "Edit kit settings"
    click_on "Delete this kit"
    expect(page).to have_current_path(delete_ui_device_path(device.id))
    fill_in "To confirm, type the kit name below:", with: device_name
    click_on "I understand, delete the kit"
    expect(page).to have_current_path(ui_user_path(username))
    expect(page).to have_content("The kit has been deleted!")
    expect(page).not_to have_content(device_name)
    expect(device.reload).to be_archived
  end
end
