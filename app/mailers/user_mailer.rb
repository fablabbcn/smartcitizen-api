class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome user
    @user = user
    mail to: user.to_email_s, subject: 'Welcome to SmartCitizen'
  end
end
