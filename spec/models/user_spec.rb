require 'rails_helper'

RSpec.describe User, :type => :model do

  it { is_expected.to have_secure_password }
  # it { is_expected.to validate_presence_of(:first_name) }
  # it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(30) }

  it { is_expected.to have_many(:oauth_applications) }

  it { is_expected.to have_many(:devices) }

  let(:user) { create(:user) }
  let(:homer) { build_stubbed(:user, username: 'homersimpson', email: 'homer@springfieldnuclear.com') }

  it "has an avatar"

  it "validates url" do
    expect(build(:user, url: nil)).to be_valid
    expect(build(:user, url: 'not a url')).to be_invalid
    expect(build(:user, url: 'http://google.com')).to be_valid
    expect(build(:user, url: 'https://www.facebook.com')).to be_valid
  end

  skip "validates avatar" do
    expect(build(:user, avatar: nil)).to be_valid
    expect(build(:user, avatar: 'not a url')).to be_invalid
    expect(build(:user, avatar: 'https://i.imgur.com/SZD8ADL.png')).to be_valid
    expect(build(:user, avatar: 'http://i.imgur.com/SZD8ADL.JPEG')).to be_valid
  end

  it "is invalid with an email which isn't an email adddress" do
    expect(build(:user, email: "not an email")).to be_invalid
  end

  it "is invalid without an email" do
    expect(build(:user, email: nil)).to be_invalid
  end

  it "is invalid with an email which is already taken" do
    create(:user, email: "taken@example.com")
    expect(build(:user, email: "taken@example.com")).to be_invalid
  end

  it "has a location" do
    user = create(:user, country_code: 'es', city: 'Barcelona')
    expect(user.country.to_s).to eq("Spain")
    expect(user.country_name).to eq("Spain")
    expect(user.city).to eq("Barcelona")
  end

  skip "has name and to_s" do
    expect(homer.name).to eq('Homer Simpson')
    expect(homer.to_s).to eq('Homer Simpson')
  end

  it "has to_email_s" do
    expect(homer.to_email_s).to eq("homersimpson <homer@springfieldnuclear.com>")
  end

  it "can send_password_reset" do
    expect(user.password_reset_token).to be_blank
    expect(last_email).to be_nil
    user.send_password_reset
    expect(user.password_reset_token).to be_present
    expect(last_email.to).to eq([user.email])
  end

  describe "forwarding" do
    describe "generating a forwarding token" do
      context "when the user is a citizen" do
        it "does not generate a forwarding token or username" do
          user.role_mask = 0
          user.regenerate_forwarding_tokens!
          expect(user.forwarding_token).to be(nil)
          expect(user.forwarding_username).to be(nil)
        end
      end
      context "when the user is a researcher" do
        it "generates a forwarding token and username" do
          user.role_mask = 2
          user.regenerate_forwarding_tokens!
          expect(user.forwarding_token).not_to be(nil)
          expect(user.forwarding_username).not_to be(nil)
        end
      end
      context "when the user is an admin" do
        it "generates a forwarding token and username" do
          user.role_mask = 5
          user.regenerate_forwarding_tokens!
          expect(user.forwarding_token).not_to be(nil)
          expect(user.forwarding_username).not_to be(nil)
        end
      end
    end

    describe "forwarding device readings" do
      context "when the user has a forwarding token" do
        it "forwards device readings" do
          user.forwarding_token = double(:forwarding_token)
          expect(user.forward_device_readings?).to be(true)
        end
      end

      context "when the user has no forwarding token" do
        it "does not forward device readings" do
          user.forwarding_token = nil
          expect(user.forward_device_readings?).to be(false)
        end
      end
    end
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
      let(:legacy_user) { create(:user, old_data: { password: Digest::SHA1.hexdigest('123pass') })}
      before(:each) do
        set_env_var('old_salt', '123')
        legacy_user.update_attribute(:password_digest, nil)
      end

      it "authenticates legacy users" do
        expect { legacy_user.authenticate('pass') }.to raise_error(BCrypt::Errors::InvalidHash)
        expect(legacy_user.authenticate_with_legacy_support('pass')).to eq(legacy_user)
        expect(legacy_user.authenticate('pass')).to eq(legacy_user)
      end

      it "does not authenticate legacy users with invalid passwords" do
        expect(legacy_user.authenticate_with_legacy_support('wrong')).to be_falsey
      end
    end

  end

  describe "roles" do
    it "is a 'citizen' when the role_mask is < 2" do
      (0..1).each do |mask|
        expect(build_stubbed(:user, role_mask: mask).role).to eq('citizen')
      end
    end

    it "is a 'researcher' when the role_mask is < 5" do
      (2..4).each do |mask|
        expect(build_stubbed(:user, role_mask: mask).role).to eq('researcher')
      end
    end

    it "is an 'admin' when the role_mask is >= 5" do
      (5..8).each do |mask|
        expect(build_stubbed(:user, role_mask: mask).role).to eq('admin')
      end
    end
  end

  describe "generating forwarding tokens" do
    context "on creating a new admin user" do
      it "generates forwarding tokens" do
        user = build(:user, role_mask: 7)
        user.save!
        expect(user.forwarding_token).not_to be(nil)
        expect(user.forwarding_username).not_to be(nil)
      end
    end

    context "on creating a new researcher user" do
      it "generates forwarding tokens" do
        user = build(:user, role_mask: 4)
        user.save!
        expect(user.forwarding_token).not_to be(nil)
        expect(user.forwarding_username).not_to be(nil)
      end
    end

    context "on creating a new citizen user" do
      it "does not generate forwarding tokens" do
        user = build(:user, role_mask: 0)
        user.save!
        expect(user.forwarding_token).to be(nil)
        expect(user.forwarding_username).to be(nil)
      end
    end

    context "on upgrading a user" do
      context "when the user already has forwarding tokens" do
        it "does not generate new tokens" do
          user = build(:user, role_mask: 4)
          user.save!
          existing_token = user.forwarding_token
          existing_username = user.forwarding_username
          user.reload

          user.role_mask = 7
          user.save!

          expect(user.forwarding_token).not_to be(nil)
          expect(user.forwarding_username).not_to be(nil)

          expect(user.forwarding_token).to eq(existing_token)
          expect(user.forwarding_username).to eq(existing_username)
        end
      end

      context "when the user does not have forwarding tokens" do
        it "generates new tokens" do
          user = build(:user, role_mask: 0)
          user.save!

          user.role_mask = 7
          user.save!

          expect(user.forwarding_token).not_to be(nil)
          expect(user.forwarding_username).not_to be(nil)
        end
      end
    end
  end


  describe "states" do
    it "has a default active state" do
      expect(user.workflow_state).to eq('active')
    end

    it "can be archived" do
      user.archive!
      user.reload
      expect(user.workflow_state).to eq('archived')
    end

    it "can be unarchived from archive state" do
      user.archive!
      user.unarchive!
      user.reload
      expect(user.workflow_state).to eq('active')
    end

    it "only returns active users by default (default_scope)" do
      User.unscoped.delete_all # < needed because database_cleaner doesn't delete User.unscoped
      a = create(:user)
      b = create(:user, workflow_state: :archived)
      expect(User.all).to eq([a])
    end

  end

end
