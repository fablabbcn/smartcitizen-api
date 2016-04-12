module V0
  class ApplicationsController < ApplicationController

    before_action :check_if_authorized!
    skip_after_action :verify_authorized # see naming conflict comment below

    def index
      @applications = current_user.oauth_applications
    end

    def show
      @application = current_user.oauth_applications.find(params[:id])
      # authorize @application < naming conflict with policies/application_policy.rb
    end

    def create
      @application = current_user.oauth_applications.build(application_params)
      # authorize @application
      if @application.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @application.errors
      end
    end

    def update
      @application = current_user.oauth_applications.find(params[:id])
      # authorize @application
      if @application.update_attributes(application_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @application.errors
      end
    end

    def destroy
      @application = current_user.oauth_applications.find(params[:id])
      # authorize @application
      if @application.destroy
        render json: {message: 'OK'}, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @application.errors
      end
    end

private

    def application_params
      params.permit(:name, :redirect_uri, :scopes)
    end

  end
end
