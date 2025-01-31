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


  scenario "User edits an experiment" do
    password = "password123"
    username = "username"
    device_name = "devicename"
    experiment_name = "experimentname"
    user = create(:user, username: username, password: password, password_confirmation: password)
    device = create(:device, name: device_name, owner: user)
    experiment = create(:experiment, owner: user, devices: [device], name: experiment_name)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    expect(page).to have_content(experiment_name)
    click_on experiment_name
    expect(page).to have_current_path(ui_experiment_path(experiment.id))
    click_on "Edit experiment settings"
    expect(page).to have_current_path(edit_ui_experiment_path(experiment.id))
    fill_in "Name", with: "new experiment name"
    click_on "Update"
    expect(page).to have_current_path(ui_experiment_path(experiment.id))
    expect(page).to have_content("new experiment name")
  end

  scenario "User creates an experiment" do
    password = "password123"
    username = "username"
    user = create(:user, username: username, password: password, password_confirmation: password)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    expect(page).to have_current_path(ui_user_path(user.username))
    click_on "Create an experiment"
    expect(page).to have_current_path(new_ui_experiment_path)
    fill_in "Name", with: "new experiment name"
    click_on "Create"
    expect(page).to have_current_path(ui_experiment_path(Experiment.last.id))
    expect(page).to have_content("new experiment name")
  end


  scenario "User deletes an experiment" do
    password = "password123"
    username = "username"
    device_name = "devicename"
    experiment_name = "experimentname"
    user = create(:user, username: username, password: password, password_confirmation: password)
    device = create(:device, name: device_name, owner: user)
    experiment = create(:experiment, owner: user, devices: [device], name: experiment_name)
    visit "/login"
    fill_in "Username or email", with: user.email
    fill_in "Password", with: password
    click_on "Sign into your account"
    click_on experiment_name
    click_on "Edit experiment settings"
    click_on "Delete this experiment"
    expect(page).to have_current_path(delete_ui_experiment_path(experiment.id))
    fill_in "To confirm, type the experiment name below:", with: experiment_name
    click_on "I understand, delete the experiment"
    expect(page).to have_current_path(ui_user_path(username))
    expect(page).to have_content("The experiment has been deleted!")
    expect(page).not_to have_content(experiment_name)
    expect(Experiment.where(id: experiment.id).first).to be_nil
  end
end
