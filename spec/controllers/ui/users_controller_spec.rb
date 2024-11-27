require "rails_helper"

describe Ui::UsersController do

  let(:user) { create(:user) }

  describe "index" do
    it "renders the template" do
        get :index
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
    end
  end

  describe "show" do
    it "renders the template" do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
    end
  end

  describe "new" do
    context "when no user is logged in" do
      it "renders the new user form" do
        get :new
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end

    context "when a user is logged in" do
      it "displays an error message and redirects to the ui users path" do
        get :new, session: { user_id: user.id }
        expect(response).to redirect_to(ui_users_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "create" do
    let(:user_params) {
      {
        username: "test_user",
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123",
        ts_and_cs: "1"
      }
    }
    context "when a user is logged in" do
      it "displays an error message and redirects to the ui users path, without creating a user" do
        expect_any_instance_of(User).not_to receive(:save)
        post :create, params: { user: user_params }, session: { user_id: user.id }
        expect(response).to redirect_to(ui_users_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when no user is logged in" do
      context "when the parameters provided are valid" do
        it "creates a user, logs them in, and redirects to the ui user path" do
          expect_any_instance_of(User).to receive(:save)
          post :create, params: { user: user_params }, session: { user_id: nil }
          expect(response).to redirect_to(ui_users_path)
          expect(flash[:success]).to be_present
        end
      end

      context "when the parameters provided are not valid" do
        let(:user_params) {
          {
            username: "test_user",
            email: "test_example.com",
            password: "password123",
            password_confirmation: "anotherpassword",
            ts_and_cs: nil
          }
        }

        it "does not create a user, and renders the new user page" do
          expect_any_instance_of(User).not_to receive(:save)
          post :create, params: { user: user_params }, session: { user_id: nil }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
          expect(flash[:alert]).to be_present
        end
      end
    end
  end


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
