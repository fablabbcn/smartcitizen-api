class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.with(user: User.first).welcome(User.first.id)
  end

  def password_reset
    UserMailer.with(user: User.first).welcome(User.first.id)
  end

end
