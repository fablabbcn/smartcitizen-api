# == Schema Information
#
# Table name: orphans
#
#  id          :integer          not null, primary key
#  session_key :string
#  data        :json
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Orphan < ActiveRecord::Base

  before_save :get_key

  class << self
    def get_new_key
      o = Orphan.new
      o.save!
      o.reload
      o.session_key
    end

    def remove_old #last 24 hrs
      Orphan.where(['created_at < ?', DateTime.now - 24.hours]).destroy_all
    end

  end

  def post_data!(params)
    data = self.post_data #from what I remember you need to do this for active record to know the value was updated
    data.merge!(params[:data])
    self.post_data = data
    self.save!
  end


  private
  def get_key
    self.session_key = SecureRandom.base64(8)
  end

end
