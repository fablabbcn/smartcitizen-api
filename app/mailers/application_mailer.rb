class ApplicationMailer < ActionMailer::Base
  default from: "SmartCitizen Notifications <notifications@mailbot.smartcitizen.me>",
    reply_to: "SmartCitizen Team <team@smartcitizen.me>"
  # layout 'mailer'
end
