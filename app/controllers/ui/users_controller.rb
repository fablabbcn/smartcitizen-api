module Ui
  class UsersController < ApplicationController
    include SharedControllerMethods
    def index
      @title = I18n.t(:users_index_title)
    end
  end
end
