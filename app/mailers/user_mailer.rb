require 'fog'

class UserMailer < ApplicationMailer

  def welcome user_id
    @user = User.find(user_id)
    mail to: @user.to_email_s, subject: 'Welcome to SmartCitizen'
  end

  def password_reset user_id
    @user = User.find(user_id)
    mail to: @user.to_email_s, subject: 'Password Reset Instructions'
  end

  def device_archive device_id, user_id
    @user = User.find(user_id)

    @url = DeviceArchive.create(device_id).url(1.day.from_now) # unless Rails.env.test?

    mail to: @user.to_email_s, subject: 'Device CSV Archive Ready'
  end

end
