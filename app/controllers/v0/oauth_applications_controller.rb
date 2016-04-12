# require 'oauth2'
# require 'json'
# require 'open-uri'
# app = JSON.parse(open("https://api.smartcitizen.me/v0/applications?access_token=ACCESS_TOKEN").read)[0]
# client = OAuth2::Client.new(app['uid'], app['secret'], site: 'https://id.smartcitizen.me')
# client.auth_code.authorize_url(redirect_uri: app['redirect_uri'])
# access = client.auth_code.get_token(RESPONSE_TOKEN, redirect_uri: app['redirect_uri'])

module V0
  class OauthApplicationsController < ApplicationController

    before_action :check_if_authorized!
    before_action :set_oauth_application, only: [:show, :update, :destroy]

    def index
      @oauth_applications = current_user.oauth_applications
    end

    def show
      authorize @oauth_application
    end

    def create
      @oauth_application = current_user.oauth_applications.build(oauth_application_params)
      authorize @oauth_application
      if @oauth_application.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @oauth_application.errors
      end
    end

    def update
      authorize @oauth_application
      if @oauth_application.update_attributes(oauth_application_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @oauth_application.errors
      end
    end

    def destroy
      authorize @oauth_application
      if @oauth_application.destroy
        render json: {message: 'OK'}, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @oauth_application.errors
      end
    end

private

    def oauth_application_params
      params.permit(:name, :redirect_uri, :scopes)
    end

    def set_oauth_application
      @oauth_application = current_user.oauth_applications.find(params[:id])
    end

  end
end
