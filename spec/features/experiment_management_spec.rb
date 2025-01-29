require "rails_helper"
feature "Experiment management" do
  scenario "User views an experiment" do
    password = "password123"
    username = "username"
    device_name = "devicename"
    experiment_name = "experimentname"
    measurement_name = "measurementname"
    user = create(:user, username: username, password: password, password_confirmation: password)
    measurement = create(:measurement, name: "measurementname")
    sensor = create(:sensor, measurement: measurement)
    component = build(:component, sensor: sensor)
    device = create(:device, name: device_name, owner: user, components: [component])
    experiment = create(:experiment, owner: user, devices: [device], name: experiment_name)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content(experiment_name)
    click_on experiment_name
    expect(page).to have_current_path(ui_experiment_path(experiment.id))
    expect(page).to have_content(experiment_name)
    click_on "Readings"
    expect(page).to have_current_path(readings_ui_experiment_path(experiment.id, measurement_id: measurement.id))
    expect(page).to have_content(experiment_name)
    expect(page).to have_content(measurement_name)
  end
end
