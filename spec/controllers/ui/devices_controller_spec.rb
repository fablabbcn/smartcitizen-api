require "rails_helper"

describe Ui::DevicesController do

  let(:user) { create(:user) }
  let(:owner) { user || create(:user) }
  let(:is_private) { false }
  let(:device) { create(:device, owner: owner, is_private: is_private) }

  describe "show" do
    context "when the device is public" do
      context "when no user is logged in" do
        let(:user) { nil }

        it "renders the template" do
          get :show, params: { id: device.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        end
      end

      context "when a user different to the device's owner is logged in" do
        let(:owner) { create(:user) }

        it "renders the template" do
          get :show, params: { id: device.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        end
      end

      context "when the user's owner is logged in" do
        it "renders the template" do
          get :show, params: { id: device.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        end
      end
    end

    context "when the device is private" do
      let(:is_private) { true }

      context "when no user is logged in" do
        let(:user) { nil }

        it "displays an error message and redirects to the login page" do
          get :show, params: { id: device.id }, session: { user_id: user.try(:id) }
          expect(response).to redirect_to(login_path)
          expect(flash[:alert]).to be_present
        end
      end

      context "when a user different to the device's owner is logged in" do
        let(:owner) { create(:user) }

        it "displays an error message and redirects to the user's profile" do
          get :show, params: { id: device.id }, session: { user_id: user.try(:id) }
          expect(response).to redirect_to(ui_user_path(user.username))
          expect(flash[:alert]).to be_present
        end
      end

      context "when the user's owner is logged in" do
        it "renders the template" do
          get :show, params: { id: device.id }, session: { user_id: user.try(:id) }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe "edit" do
    context "when no user is logged in" do
      let(:user) { nil }
      it "displays an error message and redirects to the login page" do
        get :edit, params: { id: device.id }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when a user different to the device's owner is logged in" do
      let(:owner) { create(:user) }
      it "displays an error message and redirects to the user's profile" do
        get :edit, params: { id: device.id }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(ui_user_path(user.username))
        expect(flash[:alert]).to be_present
      end
    end

    context "when the device's owner is logged in" do
      it "renders the template" do
        get :edit, params: { id: device.id }, session: { user_id: user.try(:id) }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "update" do
    context "when no user is logged in" do
      let(:user) { nil }
      it "does not update the device, displays an error message and redirects to the login page" do
        expect_any_instance_of(Device).not_to receive(:update)
        put :update, params: { id: device.id, device: { name: "new name"} }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when a user different to the device's owner is logged in" do
      let(:owner) { create(:user) }
      it "does not update the device, displays an error message and redirects to the user's profile" do
        expect_any_instance_of(Device).not_to receive(:update)
        put :update, params: { id: device.id, device: { name: "new name" } }, session: { user_id: user.try(:id) }
        expect(response).to redirect_to(ui_user_path(user.username))
        expect(flash[:alert]).to be_present
      end
    end

    context "when the device's owner is logged in" do
      context "when the provided data is valid" do
        it "updates the device and redirects back to the device page" do
          put :update,
            params: {
              id: device.id,
              device: { name: "new name" }
            },
            session: { user_id: user.id }
          expect(response).to redirect_to(ui_device_path(device.id))
          expect(flash[:success]).to be_present
          expect(device.reload.name).to eq("new name")
        end
      end

      context "when the provided data is invalid" do
        it "does not update the device, and renders the form" do
          old_exposure = device.exposure
          put :update,
            params: {
              id: device.id,
              device: { exposure: "not an exposure" }
            },
            session: { user_id: user.id }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
          expect(flash[:alert]).to be_present
          expect(device.reload.exposure).to eq(old_exposure)
        end
      end
    end
  end
end
