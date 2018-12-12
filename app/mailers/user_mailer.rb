class UserMailer < ApplicationMailer

  def welcome user_id
    @user = User.find(user_id)
    mail to: @user.to_email_s, subject: 'Welcome to SmartCitizen', from: "SmartCitizen Notifications - Welcome <notifications@mailbot.smartcitizen.me>"
  end

  def password_reset user_id
    @user = User.find(user_id)
    mail to: @user.to_email_s, subject: 'Password Reset Instructions', from: "SmartCitizen Notifications - Password <notifications@mailbot.smartcitizen.me>"
  end

  def device_archive device_id, user_id
    @user = User.find(user_id)

    @url = DeviceArchive.create(device_id).url(1.day.from_now)

    @device = Device.find(device_id)

    mail to: @user.to_email_s, subject: 'Device CSV Archive Ready'
  end

end
