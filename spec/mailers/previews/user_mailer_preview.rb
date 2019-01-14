class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.with(user: User.first).welcome(User.first.id)
  end

  def password_reset
    UserMailer.password_reset(User.first.id)
  end

  def device_archive
    UserMailer.device_archive(User.first.devices.first.id, User.first.id)
  end
  def device_battery_low
    UserMailer.device_battery_low(User.first.devices.first.id, User.first.id)
  end
end
