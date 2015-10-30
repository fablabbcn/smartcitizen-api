require 'rails_helper'

RSpec.describe Upload, type: :model do

  it { is_expected.to belong_to(:user) }

  let(:user) { create(:user) }
  let(:upload) { create(:upload, user: user, original_filename: 'testing.jpg') }

  it "has a new_filename" do
    expect(upload.new_filename).to eq("#{upload.created_at.to_i.to_s(32)}.testing.jpg")
  end

  it "generates key on create and has full_path" do
    Timecop.freeze do
      expect(upload.key).to eq("avatars/#{upload.user.uuid[0..2]}/#{upload.created_at.to_i.to_s(32)}.testing.jpg")
      expect(upload.full_path).to eq("https://images.smartcitizen.me/s100/#{upload.key}")
    end
  end

end
