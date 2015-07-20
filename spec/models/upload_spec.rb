require 'rails_helper'

RSpec.describe Upload, type: :model do
  it "has key" do
    Timecop.freeze do
      upload = create(:upload, original_filename: 'test.jpg')
      expect(upload.key).to eq("#{Time.now.to_i}-test.jpg")
    end
  end
end
