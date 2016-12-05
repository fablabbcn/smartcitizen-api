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
    # needs to be extracted out of here!
    @device = Device.find(device_id)
    @user = User.find(user_id)

    data = {}
    sensor_headers = []
    keys_length = @device.kit.sensor_map.keys.length
    @device.kit.sensor_map.keys.each_with_index do |key, index|
      query = {metrics:[{tags:{device_id:[device_id]},name: key}], cache_time: 0, start_absolute: 1262304000000}
      response = Kairos.http_post_to("/datapoints/query",query)
      metric_id = @device.find_sensor_id_by_key(key)
      if component = @device.components.detect{|c|c["sensor_id"] == metric_id}
        values = JSON.parse(response.body)['queries'][0]['results'][0]['values']
        values.each do |v|
          time = Time.at(v[0]/1000).utc
          data[time] ||= Array.new(keys_length)
          data[time][index] = component.calibrated_value(v[1])
        end
      end
      sensor = Sensor.find(@device.kit.sensor_map[key])
      sensor_headers << "#{sensor.measurement.name} in #{sensor.unit} (#{sensor.name})"
    end

    csv = "timestamp,#{sensor_headers.join(',')}\n"
    csv += data.map{|d| d.join(",")}.join("\n")

    s3 = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['aws_access_key'],
      :aws_secret_access_key    => ENV['aws_secret_key'],
      :region                   => ENV['aws_region'],
    })

    unless Rails.env.test?
      # directory = s3.directories.get(ENV['s3_bucket'])
      key = "devices/#{device_id}/csv_archive.csv"
      file = s3.directories.new(:key => ENV['s3_bucket']).files.new({
        :key    => key,
        :body   => csv,
        :public => false,
        :expires => 1.day,
        :content_type => 'text/csv',
        :content_disposition => "attachment; filename=#{@device.id}.csv"
      })
      file.save
      @url = file.url(1.day.from_now)
    end

    # connection.directories.new(:key => ENV['s3_bucket']).files.new(:key => key).url(1.day.from_now)

    mail to: @user.to_email_s, subject: 'Device CSV Archive Ready'
  end

end
