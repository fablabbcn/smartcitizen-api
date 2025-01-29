require "rails_helper"

describe Ui::ExperimentsController do
  let(:user) { create(:user) }
  let(:owner) { user || create(:user) }
  let(:experiment) { create(:experiment, owner: owner) }

  describe "show" do
    context "when no user is logged in" do
      let(:user) { nil }

      it "renders the template" do
        get :show, params: { id: experiment.id }, session: { user_id: user.try(:id) }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

    context "when a user different to the experiment's owner is logged in" do
      let(:owner) { create(:user) }

      it "renders the template" do
        get :show, params: { id: experiment.id }, session: { user_id: user.try(:id) }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

    context "when the user's owner is logged in" do
      it "renders the template" do
        get :show, params: { id: experiment.id }, session: { user_id: user.try(:id) }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end
  end

  describe "readings" do
    let(:measurement) { create(:measurement)}

    before(:each) do
      sensor = create(:sensor, measurement: measurement)
      component =  build(:component, sensor: sensor)
      device = create(:device, components: [component])
      experiment.devices << device
      experiment.save!
    end

    describe "when a measurement_id is passed" do
      context "when no user is logged in" do
        let(:user) { nil }


        it "renders the template" do
          get :readings, params: { id: experiment.id, measurement_id: measurement.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:readings)
        end
      end

      context "when a user different to the experiment's owner is logged in" do
        let(:owner) { create(:user) }

        it "renders the template" do
          get :readings, params: { id: experiment.id, measurement_id: measurement.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:readings)
        end
      end

      context "when the user's owner is logged in" do
        it "renders the template" do
          get :readings, params: { id: experiment.id, measurement_id: measurement.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:readings)
        end
      end
    end

    describe "when no measurement_id is passed" do
      context "when no user is logged in" do
        let(:user) { nil }


        it "redirects to the first measurement for the experiment" do
          get :readings, params: { id: experiment.id }, session: { user_id: user.try(:id) }
          expect(response).to redirect_to(readings_ui_experiment_path(experiment.id, measurement_id: measurement.id))
        end
      end

      context "when a user different to the experiment's owner is logged in" do
        let(:owner) { create(:user) }

        it "redirects to the first measurement for the experiment" do
          get :readings, params: { id: experiment.id }, session: { user_id: user.try(:id) }
          expect(response).to redirect_to(readings_ui_experiment_path(experiment.id, measurement_id: measurement.id))
        end
      end

      context "when the user's owner is logged in" do
        it "redirects to the first measurement for the experiment" do
          get :readings, params: { id: experiment.id }, session: { user_id: user.try(:id) }
          expect(response).to redirect_to(readings_ui_experiment_path(experiment.id, measurement_id: measurement.id))
        end
      end
    end
  end
end
