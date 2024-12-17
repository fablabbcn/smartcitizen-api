module Ui
  class DevicesController < ApplicationController
    def show
      find_device!
      return unless authorize_device! :show?, :show_device_forbidden
      @title = I18n.t(:show_device_title, name: @device.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@device.owner, current_user)), ui_user_path(@device.owner.username)],
        [@title, ui_device_path(@device.id)]
      )
      render "show", layout: "base"
    end

    def edit
      find_device!
      return unless authorize_device! :update?, :edit_device_forbidden
      @title = I18n.t(:edit_device_title, name: @device.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@device.owner, current_user)), ui_user_path(@device.owner.username)],
        [I18n.t(:show_device_title, name: @device.name), ui_device_path(@device.id)],
        [@title, edit_ui_device_path(@device.id)]
      )
    end

    private

    def find_device!
      @device = Device.find(params[:id])
    end

    def authorize_device!(action, alert)
      return true if authorize? @device, action
      flash[:alert] = I18n.t(alert)
      redirect_to current_user ? ui_user_path(current_user.username) : login_path
      return false
    end
  end
end
