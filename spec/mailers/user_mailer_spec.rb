require "rails_helper"

describe UserMailer, type: :mailer do
  before(:all) do
    create(:kit, id: 3, name: 'SCK', description: "Board", slug: 'sck', sensor_map: '{"temp": 12, "light": 14}')
    create(:sensor, id:12, name:'HPP828E031', description: 'test')
    create(:sensor, id:14, name:'BH1730FVC', description: 'test')
    create(:component, id: 12, board: Kit.find(3), sensor: Sensor.find(12), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
    create(:component, id: 14, board: Kit.find(3), sensor: Sensor.find(14), equation: 'x', reverse_equation: 'x/10.0')
  end

  let(:user) { create(:user) }
  let(:device) { create(:device, kit: Kit.find(3), owner: user) }

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
    before do
      def kairos_query(key)
        {metrics:[{tags:{device_id:[device.id]},name: key}], cache_time: 0, start_absolute: 1262304000000}
      end
      kairos_temp = RestClient::Response.new('{"queries":[{"results":[{"values":[[1364968800000,1.0],[1366351200000,1.0]]}]}]}')
      kairos_light = RestClient::Response.new('{"queries":[{"results":[{"values":[[1364968800000,3.0],[1366351200000,3.0]]}]}]}')

      allow(Kairos).to receive(:http_post_to).with("/datapoints/query",kairos_query('temp')).and_return(kairos_temp)
      allow(Kairos).to receive(:http_post_to).with("/datapoints/query",kairos_query('light')).and_return(kairos_light)

      expected_csv = "timestamp,temp,light\n"\
                     "2013-04-03 06:00:00 UTC,-52.997318725585934,3.0\n"\
                     "2013-04-19 06:00:00 UTC,-52.997318725585934,3.0\n"
    end

    let(:mail) { UserMailer.device_archive(device.id, user.id) }

    it 'puts csv in order to see what is going on' do
      # UserMailer.send(:device_archive)
      # UserMailer.device_archive(device.id, user.id)
    end

    it "sends device_archive email" do
      expect(mail.subject).to eq("Device CSV Archive Ready")
      # expect(mail.to).to eq([user.email])
      # expect(mail.from).to eq(["notifications@mailbot.smartcitizen.me"])
      # expect(mail.reply_to).to eq(["team@smartcitizen.me"])
      # expect(mail.body.encoded).to match('device_url')
    end
  end

end
