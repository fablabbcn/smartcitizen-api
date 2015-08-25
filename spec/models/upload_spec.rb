require 'rails_helper'

RSpec.describe Upload, type: :model do

  it "has key and fullpath" do
    Timecop.freeze do
      user = create(:user)
      user.reload
      upload = create(:upload, user: user, original_filename: 'test.jpg')
      expect(upload.key).to eq("avatars/#{upload.user.uuid[0..2]}/#{upload.created_at.to_i.to_s(32)}.test.jpg")
      expect(upload.full_path).to eq("https://images.smartcitizen.me/s100/#{upload.key}")
    end
  end
end
