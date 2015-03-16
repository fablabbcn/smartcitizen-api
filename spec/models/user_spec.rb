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
  let(:homer) { build_stubbed(:user, first_name: "Homer", last_name: 'Simpson', email: 'homer@springfieldnuclear.com') }

  it "has an avatar"

  it "has a location" do
    user = create(:user, country_code: 'es', city: 'Barcelona')
    expect(user.country.to_s).to eq("Spain")
    expect(user.city).to eq("Barcelona")
  end

  it "has api_token" do
    old_token = create(:api_token, owner: user)
    new_token = create(:api_token, owner: user)
    expect(user.api_token).to eq(new_token)
  end

  it "has name and to_s" do
    expect(homer.name).to eq('Homer Simpson')
    expect(homer.to_s).to eq('Homer Simpson')
  end

  it "has to_email_s" do
    expect(homer.to_email_s).to eq("Homer Simpson <homer@springfieldnuclear.com>")
  end

  it "can send_password_reset" do
    expect(user.password_reset_token).to be_blank
    expect(last_email).to be_nil
    user.send_password_reset
    expect(user.password_reset_token).to be_present
    expect(last_email.to).to eq([user.email])
  end

  describe "authenticate_with_legacy_support" do

    let(:user) { build_stubbed(:user, password: 'password') }

    describe "new users" do
      it "authenticates users" do
        expect(user.authenticate_with_legacy_support('password')).to eq(user)
      end

      it "does not authenticate users with invalid passwords" do
        expect(user.authenticate_with_legacy_support('wrong')).to be_falsey
      end
    end

    describe "legacy users" do
      let(:legacy_user) { create(:user, old_password: Digest::SHA1.hexdigest('123pass'))}
      before(:each) do
        set_env_var('old_salt', '123')
        legacy_user.update_attribute(:password_digest, nil)
      end

      it "authenticates legacy users" do
        expect { legacy_user.authenticate('pass') }.to raise_error
        expect(legacy_user.authenticate_with_legacy_support('pass')).to eq(legacy_user)
        expect(legacy_user.authenticate('pass')).to eq(legacy_user)
      end

      it "does not authenticate legacy users with invalid passwords" do
        expect(legacy_user.authenticate_with_legacy_support('wrong')).to be_falsey
      end
    end

  end

end
