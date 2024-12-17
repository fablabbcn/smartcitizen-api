module Ui
  class DevicesController < ApplicationController
    def show
      find_device!
      @title = I18n.t(:show_device_title, name: @device.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: possessive(@device.owner, current_user)), ui_user_path(@device.owner.username)],
        [@title, ui_device_path(@device.id)]
      )
      render "show", layout: "base"
    end

    def find_device!
      @device = Device.find(params[:id])
    end
  end
end
