class ApplicationMailer < ActionMailer::Base
  default from: "SmartCitizen Notifications <notifications@mailbot.smartcitizen.me>",
    reply_to: "SmartCitizen Support <support@smartcitizen.me>"
end
