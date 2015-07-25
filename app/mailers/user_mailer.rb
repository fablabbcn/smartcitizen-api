class UserMailer < ApplicationMailer

  def welcome user
    @user = user
    mail to: user.to_email_s, subject: 'Welcome to SmartCitizen'
  end

  def password_reset user
    @user = user
    mail to: user.to_email_s, subject: 'Password Reset Instructions'
  end

end
