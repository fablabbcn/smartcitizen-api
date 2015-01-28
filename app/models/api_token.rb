class ApiToken < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  validates_presence_of :owner

  before_create :generate_token

  def to_s
    token
  end

  def to_param
    token
  end

private

  def generate_token
    begin
      self.token = SecureRandom.uuid
    end while ApiToken.exists?(token: self.token)
  end

end
