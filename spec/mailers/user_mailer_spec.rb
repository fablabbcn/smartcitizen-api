require "rails_helper"

describe UserMailer do
  let(:user) { create(:user) }
  let(:device) { create(:device, owner: user) }

  describe "welcome" do
    let(:mail) { UserMailer.welcome(user.id) }

    it "sends welcome email" do
      expect(mail.subject).to eq("Welcome to SmartCitizen")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@mailbot.smartcitizen.me"])
      expect(mail.reply_to).to eq(["team@smartcitizen.me"])
      expect(mail.body.encoded).to match("Welcome #{user.username}")
    end
  end

  describe "password_reset" do
    let(:user) { create(:user, password_reset_token: '6789') }
    let(:mail) { UserMailer.password_reset(user.id) }

    it "sends password_reset email" do
      expect(mail.subject).to eq("Password Reset Instructions")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@mailbot.smartcitizen.me"])
      expect(mail.reply_to).to eq(["team@smartcitizen.me"])
      expect(mail.body.encoded).to match('6789')
    end
  end

  describe "device_archive" do
    let(:mail) { UserMailer.device_archive(device.id, user.id) }

    skip "sends device_archive email" do
      expect(mail.subject).to eq("Device CSV Archive Ready")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@mailbot.smartcitizen.me"])
      expect(mail.reply_to).to eq(["team@smartcitizen.me"])
      expect(mail.body.encoded).to match('device_url')
    end
  end

end
