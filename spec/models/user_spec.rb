require 'rails_helper'

RSpec.describe User, :type => :model do

  it { is_expected.to have_secure_password }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(30) }

  it { is_expected.to have_many(:api_tokens) }

  it { is_expected.to have_many(:devices) }

  let(:user) { create(:user) }

  it "has api_token" do
    old_token = create(:api_token, owner: user)
    new_token = create(:api_token, owner: user)
    expect(user.api_token).to eq(new_token)
  end

  it "has name and to_s" do
    user = build_stubbed(:user, first_name: 'Homer', last_name: 'Simpson')
    expect(user.name).to eq('Homer Simpson')
    expect(user.to_s).to eq('Homer Simpson')
  end

end
