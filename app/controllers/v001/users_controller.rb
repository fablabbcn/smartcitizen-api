module V001
  class UsersController < ApplicationController

    def show
      @user = User.find_by(id: params[:api_key])
    end

  end
end