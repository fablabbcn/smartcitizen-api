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

  describe "edit" do
    context "when no user is logged in" do
      let(:user) { nil }
      it "displays an error message and redirects to the login page" do
        get :edit, params: { id: experiment.id }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when a user different to the experiment's owner is logged in" do
      let(:owner) { create(:user) }
      it "displays an error message and redirects to the user's profile" do
        get :edit, params: { id: experiment.id }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(ui_user_path(user.username))
        expect(flash[:alert]).to be_present
      end
    end

    context "when the experiment's owner is logged in" do
      it "renders the template" do
        get :edit, params: { id: experiment.id }, session: { user_id: user.try(:id) }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end
  end


  describe "update" do

    context "when no user is logged in" do
      let(:user) { nil }
      it "does not update the experiment, displays an error message and redirects to the login page" do
        expect_any_instance_of(Experiment).not_to receive(:update)
        put :update, params: { id: experiment.id, experiment: { name: "new name"} }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when a user different to the experiment's owner is logged in" do
      let(:owner) { create(:user) }
      it "does not update the experiment, displays an error message and redirects to the user's profile" do
        expect_any_instance_of(Experiment).not_to receive(:update)
        put :update, params: { id: experiment.id, experiment: { name: "new name" } }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(ui_user_path(user.username))
        expect(flash[:alert]).to be_present
      end
    end

    context "when the experiment's owner is logged in" do
      context "when the provided data is valid" do
        it "updates the experiment and redirects back to the experiment page" do
          put :update,
            params: {
              id: experiment.id,
              experiment: { name: "new name" }
            },
            session: { user_id: user.id }
          expect(response).to redirect_to(ui_experiment_path(experiment.id))
          expect(flash[:success]).to be_present
          expect(experiment.reload.name).to eq("new name")
        end
      end

      context "when the provided data is invalid" do
        it "does not update the experiment, and renders the form" do
          old_starts_at = experiment.starts_at
          put :update,
            params: {
              id: experiment.id,
              experiment: { starts_at: "not an datetime" }
            },
            session: { user_id: user.id }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
          expect(flash[:alert]).to be_present
          expect(experiment.reload.starts_at).to eq(old_starts_at)
        end
      end
    end
  end

  describe "new" do
    context "when no user is logged in" do
      let(:user) { nil }

      it "redirects to the login page" do
        get :new, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when a user is logged in" do
      it "displays the new experiment page" do
        get :new, session: { user_id: user.try(:id) }
        expect(response).to have_http_status(:success)
        expect(assigns[:experiment]).to be_present
        expect(response).to render_template(:new)
      end
    end
  end

  describe "create" do

    let(:device) {
      create(:device)
    }

    let(:experiment_params) {
      { name: "A experiment", description: "A experiment description", device_ids: [device.id] }
    }

    context "when no user is logged in" do
      let(:user) { nil }

      it "redirects to the login page" do
        post :create, params: { experiment: experiment_params }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when a user is logged in" do
      let(:user) { create(:user) }

      context "when the parameters provided are valid" do
        it "creates a experiment and redirects to the experiment page" do
          expect_any_instance_of(Experiment).to receive(:save).and_call_original
          post :create, params: { experiment: experiment_params }, session: { user_id: user.try(:id) }
          expect(response).to redirect_to(ui_experiment_path(Experiment.last.id))
          expect(flash[:success]).to be_present
          expect(Experiment.last.name).to eq(experiment_params[:name])
          expect(Experiment.last.description).to eq(experiment_params[:description])
          expect(Experiment.last.owner).to eq(user)
          expect(Experiment.last.devices).to include(device)
        end
      end

      context "when the parameters provided are invalid" do
        let(:experiment_params) {
          { name: nil, description: "A experiment description" }
        }

        it "does not create a experiment, and rerenders the new experiment page" do
          expect_any_instance_of(Experiment).not_to receive(:save)
          post :create, params: { experiment: experiment_params }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
          expect(flash[:alert]).to be_present
        end
      end
    end
  end
end
