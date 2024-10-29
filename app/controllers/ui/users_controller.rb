module Ui
  class UsersController < ApplicationController
    include SharedControllerMethods
    def index
      @title = "User information"
    end
  end
end
