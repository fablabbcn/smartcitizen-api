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
end

