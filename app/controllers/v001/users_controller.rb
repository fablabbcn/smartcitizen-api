module V001
  class UsersController < ApplicationController

    def show
      @user = current_user
    end

  end
end