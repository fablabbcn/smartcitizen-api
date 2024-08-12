require "rails_helper"

RSpec.describe Experiment, type: :model do

  describe "#is_active?" do
    context "when the experiment has neither start or end times" do
      it "is active" do
        experiment = build(:experiment, starts_at: nil, ends_at: nil)
        expect(experiment).to be_active
      end
    end

    context "when the experiment has a start time but no end time" do
      it "is inactive before the start time" do
        experiment = build(:experiment, starts_at: Time.now + 1.hour, ends_at: nil)
        expect(experiment).not_to be_active
      end

      it "is active after the start time" do
        experiment = build(:experiment, starts_at: Time.now - 1.hour, ends_at: nil)
        expect(experiment).to be_active
      end
    end

    context "when the experiment has an end time but no start time" do
      it "is active before the end time" do
        experiment = build(:experiment, starts_at: nil, ends_at: Time.now + 1.hour)
        expect(experiment).to be_active
      end

      it "is inactive after the end time" do
        experiment = build(:experiment, starts_at: nil, ends_at: Time.now - 1.hour)
        expect(experiment).not_to be_active
      end
    end

    context "when the experiment has both start and end times" do
      it "is inactive before the start time" do
        experiment = build(:experiment, starts_at: Time.now + 1.hour, ends_at: Time.now + 2.hours)
        expect(experiment).not_to be_active
      end

      it "is active between the start and end times" do
        experiment = build(:experiment, starts_at: Time.now - 1.hour, ends_at: Time.now + 1.hour)
        expect(experiment).to be_active
      end

      it "is inactive after the end time" do
        experiment = build(:experiment, starts_at: Time.now - 2.hours, ends_at: Time.now - 1.hour)
        expect(experiment).not_to be_active
      end
    end
  end
end
