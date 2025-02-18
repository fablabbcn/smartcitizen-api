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
    click_on "Edit kit", match: :first
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
    click_on "Edit kit", match: :first
    click_on "Delete this kit"
    expect(page).to have_current_path(delete_ui_device_path(device.id))
    fill_in "To confirm, type the kit name below:", with: device_name
    click_on "I understand, delete the kit"
    expect(page).to have_current_path(ui_user_path(username))
    expect(page).to have_content("The kit has been deleted!")
    expect(page).not_to have_content(device_name)
    expect(device.reload).to be_archived
  end

  scenario "User downloads CSV archive for a device" do
    fake_file = double(:file)
    allow(fake_file).to receive(:url).and_return("https://example.com")
    allow(DeviceArchive).to receive(:create).and_return(fake_file)
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
    click_on "Download data as CSV", match: :first
    click_on "Request data download"
    expect(page).to have_current_path(ui_device_path(device.id))
    expect(page).to have_content("Your CSV download has been requested, you'll shortly receive an email with a download link!")
  end

  scenario "User adds a new legacy device" do
    password = "password123"
    username = "username"
    device_name = "devicename"
    user = create(:user, username: username, password: password, password_confirmation: password)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    click_on "Register a new kit", match: :first
    click_on "Legacy Smart Citizen Kit version 1.0 and 1.1"
    fill_in "Name", with: "kit name"
    fill_in "Description", with: "kit description"
    fill_in "MAC address", with: "2b:84:b1:3e:24:1b"
    select "Indoor", from: "Exposure"
    select "Smart Citizen Kit 1.1", from: "Hardware version"
    check "Enable precise location"
    click_on "Register"
    expect(page).to have_current_path(ui_device_path(Device.last.id))
    expect(page).to have_content("The kit has been registered!")
    expect(page).to have_content("kit name")
    expect(page).to have_content("kit description")
  end

  scenario "User uploads a data CSV for a device" do
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
    click_on "Upload data as CSV", match: :first
    attach_file "Choose CSV files", "#{File.dirname(__FILE__)}/../fixtures/fake_device_data.csv"
    click_button "Upload"
    expect(page).to have_current_path(ui_device_path(device.id))
    expect(page).to have_content("Your data has been uploaded succesfully!")
  end
end
