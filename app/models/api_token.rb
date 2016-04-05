# This class is not being used, it is due to be deprecated

class ApiToken < ActiveRecord::Base

  belongs_to :owner, class_name: 'User'
  validates_presence_of :owner
  validates_uniqueness_of :token

  before_create :generate_token

  def to_s
    token
  end

  def to_param
    token
  end

private

  def generate_token
    unless token
      begin
        self.token = SecureRandom.uuid
      end while ApiToken.exists?(token: self.token)
    end
  end

end
