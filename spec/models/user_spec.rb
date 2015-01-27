require 'rails_helper'

RSpec.describe User, :type => :model do

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to validate_uniqueness_of(:username) }

  it { is_expected.to have_many(:devices) }

  it "has name" do
    user = build_stubbed(:user, first_name: 'Homer', last_name: 'Simpson')
    expect(user.name).to eq('Homer Simpson')
    expect(user.to_s).to eq('Homer Simpson')
  end

end
