require 'rails_helper'

describe V0::ExperimentsController do

  let(:application) { create :application }

  let(:citizen_user) { create :user }
  let(:citizen_token) { create :access_token, application: application, resource_owner_id: citizen_user.id }

  let(:admin_user) { create :admin }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin_user.id }

  let(:owner_user) { create :user }
  let(:owner_token) { create :access_token, application: application, resource_owner_id: owner_user.id }

  let(:experiment) {
    create(:experiment, name: "Existing experiment", owner: owner_user)
  }

  let(:device) { create(:device) }
  let(:valid_params) {
    {
      name: "test experiment",
      description: "a test experiment",
      is_test: false,
      starts_at: "2024-01-01T00:00:00Z",
      ends_at: "2024-06-30T23:59:59Z",
      device_ids: [ device.id ]
    }
  }

  describe "GET /experiments" do
    it "lists all experiments" do
      first = create(:experiment, name: "first experiment")
      second = create(:experiment, name: "second experiment")
      j = api_get 'experiments'

      expect(j.length).to eq(2)
      expect(j[0]['name']).to eq('first experiment')
      expect(j[1]['name']).to eq('second experiment')
      expect(response.status).to eq(200)
    end
  end

  describe "POST /experiments" do
    context "When no user is logged in" do
      it "does not create an experiment" do
        before_count = Experiment.count
        api_post "experiments", valid_params

        expect(response.status).to eq(401)
        expect(Experiment.count).to eq(before_count)
      end
    end

    context "When a user is logged in" do
      it "creates an experiment" do
        before_count = Experiment.count
        api_post "experiments", valid_params.merge(access_token: citizen_token.token)

        expect(response.status).to eq(201)
        expect(Experiment.count).to eq(before_count + 1)
        created = Experiment.last
        expect(created.name).to eq(valid_params[:name])
        expect(created.description).to eq(valid_params[:description])
        expect(created.is_test).to eq(valid_params[:is_test])
        expect(created.starts_at).to eq(Time.parse(valid_params[:starts_at]))
        expect(created.ends_at).to eq(Time.parse(valid_params[:ends_at]))
        expect(created.device_ids).to eq(valid_params[:device_ids])
      end
    end
  end

  describe "GET /experiments/:id" do

    it "returns the experiment" do
      json = api_get "experiments/#{experiment.id}"

      expect(response.status).to eq(200)
      expect(json["name"]).to eq experiment.name
    end
  end

  describe "PUT /experiments/:id" do
    context "When no user is logged in" do
      it "does not update the experiment" do
        json = api_put "experiments/#{experiment.id}", valid_params

        updated = Experiment.find(experiment.id)
        expect(response.status).to eq(401)
        expect(updated).to eq(experiment)
      end
    end

    context "When the experiment owner is logged in" do
      it "updates the experiment" do
        json = api_put "experiments/#{experiment.id}", valid_params.merge(access_token: owner_token.token)

        updated = Experiment.find(experiment.id)
        expect(updated.name).to eq(valid_params[:name])
        expect(updated.description).to eq(valid_params[:description])
        expect(updated.is_test).to eq(valid_params[:is_test])
        expect(updated.starts_at).to eq(Time.parse(valid_params[:starts_at]))
        expect(updated.ends_at).to eq(Time.parse(valid_params[:ends_at]))
        expect(updated.device_ids).to eq(valid_params[:device_ids])
      end
    end

    context "When a different user is logged in" do
      it "does not update the experiment" do
        json = api_put "experiments/#{experiment.id}", valid_params.merge(access_token: citizen_token.token)

        expect(response.status).to eq(403)
        updated = Experiment.find(experiment.id)
        expect(updated).to eq(experiment)
      end
    end

    context "When an admin is logged in" do
      it "updates the experiment" do
        json = api_put "experiments/#{experiment.id}", valid_params.merge(access_token: admin_token.token)

        updated = Experiment.find(experiment.id)
        expect(updated.name).to eq(valid_params[:name])
        expect(updated.description).to eq(valid_params[:description])
        expect(updated.is_test).to eq(valid_params[:is_test])
        expect(updated.starts_at).to eq(Time.parse(valid_params[:starts_at]))
        expect(updated.ends_at).to eq(Time.parse(valid_params[:ends_at]))
        expect(updated.device_ids).to eq(valid_params[:device_ids])
      end
    end
  end

  describe "DELETE /experiments/:id" do
    context "When no user is logged in" do
      it "does not delete the experiment" do
        json = api_delete "experiments/#{experiment.id}"

        updated = Experiment.where(id: experiment.id).first
        expect(response.status).to eq(401)
        expect(updated).not_to be(nil)
      end
    end

    context "When the experiment owner is logged in" do
      it "deletes the experiment" do
        json = api_delete "experiments/#{experiment.id}", access_token: owner_token.token

        updated = Experiment.where(id: experiment.id).first
        expect(response.status).to eq(200)
        expect(updated).to be(nil)
      end
    end

    context "When a different user is logged in" do
      it "does not delete the experiment" do
        json = api_delete "experiments/#{experiment.id}", access_token: citizen_token.token

        updated = Experiment.where(id: experiment.id).first
        expect(response.status).to eq(403)
        expect(updated).not_to be(nil)
      end
    end

    context "When an admin is logged in" do
      it "deletes the experiment" do
        json = api_delete "experiments/#{experiment.id}", access_token: admin_token.token

        updated = Experiment.where(id: experiment.id).first
        expect(response.status).to eq(200)
        expect(updated).to be(nil)
      end
    end
  end
end
