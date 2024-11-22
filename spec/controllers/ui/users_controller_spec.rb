require "rails_helper"

describe Ui::UsersController do

  let(:user) { create(:user) }

  describe "delete" do
    context "when the correct user is logged in" do
      it "displays the delete user form" do
        get :delete, params: { id: user.id }, session: { user_id: user.id }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:delete)
      end
    end

    context "when a different user is logged in" do
      let(:other_user) { create(:user) }
      it "redirects to the ui users page" do
        get :delete, params: { id: user.id }, session: { user_id: other_user.id }
        expect(response).to redirect_to(ui_users_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when no user is logged in" do
      it "redirects to the login page" do
        get :delete, params: { id: user.id }, session: { user_id: nil }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "destroy" do
    context "when the correct user is logged in" do
      context "when the correct username is provided" do
        it "archives the user, logs out and redirects to the post delete page" do
          expect_any_instance_of(User).to receive(:archive!)
          delete :destroy,
            params: { id: user.id, username: user.username },
            session: { user_id: user.id }
          expect(response).to redirect_to(post_delete_ui_users_path)
          expect(session[:user_id]).to be_nil
        end
      end

      context "when an incorrect username is provided" do
        it "does not archive the user and redirects to the delete page" do
          expect_any_instance_of(User).not_to receive(:archive!)
          delete :destroy,
            params: { id: user.id, username: "a wrong username" },
            session: { user_id: user.id }
          expect(response).to redirect_to(delete_ui_user_path(user.id))
          expect(flash[:alert]).to be_present
          expect(session[:user_id]).to eq(user.id)
        end
      end
    end

    context "when a different user is logged in" do

      let(:other_user) { create(:user) }

      it "does not archive the user and redirects to the ui users page" do
          expect_any_instance_of(User).not_to receive(:archive!)
          delete :destroy,
            params: { id: user.id, username: user.username },
            session: { user_id: other_user.id }
          expect(response).to redirect_to(ui_users_path)
          expect(flash[:alert]).to be_present
          expect(session[:user_id]).to eq(other_user.id)
      end
    end

    context "when no user is logged in" do
      it "does not archive the user and redirets to the login page" do
          expect_any_instance_of(User).not_to receive(:archive!)
          delete :destroy,
            params: { id: user.id, username: user.username },
            session: { user_id: nil }
          expect(response).to redirect_to(login_path)
          expect(flash[:alert]).to be_present
          expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "post_delete" do
    it "renders the template" do
        get :post_delete
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:post_delete)
    end
  end
end
