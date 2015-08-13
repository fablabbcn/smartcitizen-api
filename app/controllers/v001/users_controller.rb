module V001
  class UsersController < ApplicationController

    def show
      render json: Oj.dump({ me: current_user }, mode: :compat)
    end

  end
end


