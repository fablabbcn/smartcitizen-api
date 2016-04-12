module V0
  class ApplicationsController < ApplicationController

    before_action :check_if_authorized!
    after_action :verify_authorized

    def index
      @applications = current_user.oauth_applications
    end

  end
end
