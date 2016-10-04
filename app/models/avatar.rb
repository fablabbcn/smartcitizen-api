# == Schema Information
#
# Table name: uploads
#
#  id                :integer          not null, primary key
#  type              :string
#  original_filename :string
#  metadata          :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  uuid              :uuid
#  user_id           :integer
#  key               :string
#

# This is the user's profile picture, it's stored in AWS S3 and is automatically
# resized using AWS Lambda.

class Avatar < Upload
end
