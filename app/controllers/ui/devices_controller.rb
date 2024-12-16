module Ui
  class DevicesController < ApplicationController
    def show
      find_device!
      @title = I18n.t(:show_device_title, name: @device.name)
      add_breadcrumb(@title, ui_device_path(@device.id))
      render "show", layout: "base"
    end

    def find_device!
      @device = Device.find(params[:id])
    end
  end
end
