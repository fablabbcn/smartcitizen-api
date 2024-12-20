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

    def update
      find_device!
      return unless authorize_device! :update?, :edit_device_forbidden
      if @device.update(device_params)
        flash[:success] = I18n.t(:update_device_success)
        redirect_to ui_device_path(@device.id)
      else
        flash[:alert] = I18n.t(:update_device_failure)
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def device_params
      params.require(:device).permit(
        :name,
        :description,
        :exposure,
        :latitude,
        :longitude,
        :is_private,
        :precise_location,
        :enable_forwarding,
        :notify_low_battery,
        :notify_stopped_publishing,
        { :tag_ids => [] },
        { :postprocessing_attributes => :hardware_url },
      )
    end

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
