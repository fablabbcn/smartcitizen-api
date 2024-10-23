module Ui
  class ApplicationController < ActionController::Base
    layout "application"
    include SharedControllerMethods
  end
end
