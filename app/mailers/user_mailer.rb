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
        :body   => DeviceArchive.generate_csv(device_id),
        :public => false,
        :expires => 1.day,
        :content_type => 'text/csv',
        :content_disposition => "attachment; filename=#{device_id}_#{Time.now.iso8601}.csv"
      })
      file.save
      @url = file.url(1.day.from_now)
    end

    # connection.directories.new(:key => ENV['s3_bucket']).files.new(:key => key).url(1.day.from_now)

    mail to: @user.to_email_s, subject: 'Device CSV Archive Ready'
  end

end
