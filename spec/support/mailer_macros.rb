module MailerMacros
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def reset_email
    ActionMailer::Base.deliveries = []
  end
end

RSpec.configure do |config|

  config.before(:each) do
    reset_email
  end

end
