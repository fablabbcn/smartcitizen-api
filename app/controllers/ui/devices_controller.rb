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

    def delete
      find_device!
      return unless authorize_device! :destroy?, :delete_device_forbidden
      @title = I18n.t(:delete_device_title, name: @device.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@device.owner, current_user)), ui_user_path(@device.owner.username)],
        [I18n.t(:show_device_title, name: @device.name), ui_device_path(@device.id)],
        [I18n.t(:edit_device_title, name: @device.name), edit_ui_device_path(@device.id)],
        [I18n.t(:delete_device_title, name: @device.name), delete_ui_device_path(@device.id)]
      )
    end

    def destroy
      find_device!
      return unless authorize_device! :destroy?, :delete_device_forbidden
      if @device.name != params[:name]
        flash[:alert] = I18n.t(:delete_device_wrong_name)
        redirect_to delete_ui_device_path(@device.id)
        return
      end
      @device.archive!
      flash[:success] = I18n.t(:delete_device_success)
      redirect_to ui_user_path(current_user.username)
    end

    def download
      find_device!
      return unless authorize_device! :download?, :download_device_forbidden
      @title = I18n.t(:download_device_title)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@device.owner, current_user)), ui_user_path(@device.owner.username)],
        [I18n.t(:show_device_title, name: @device.name), ui_device_path(@device.id)],
        [@title, download_ui_device_path(@device.id)]
      )
    end

    def download_confirm
      find_device!
      return unless authorize_device! :download?, :download_device_forbidden
      if @device.request_csv_archive_for!(current_user)
        flash[:success] = I18n.t(:download_device_success)
      else
        flash[:alert] = I18n.t(:download_device_requested_too_soon)
      end
      redirect_to ui_device_path(@device.id)
    end

    def register
      unless current_user
        flash[:alert] = I18n.t(:register_device_forbidden)
        redirect_to login_path
        return
      end
      @title = I18n.t(:register_device_title)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(current_user, current_user, capitalize: true)), ui_user_path(current_user)],
        [@title, register_ui_devices_path]
      )
    end

    def new
      unless current_user
        flash[:alert] = I18n.t(:register_device_forbidden)
        redirect_to login_path
        return
      end
      @title = I18n.t(:new_device_title)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(current_user, current_user, capitalize: true)), ui_user_path(current_user)],
        [I18n.t(:register_device_title), register_ui_devices_path],
        [@title, new_ui_device_path]
      )
      @device = Device.new(owner: current_user)
    end

    def create
      unless current_user
        flash[:alert] = I18n.t(:register_device_forbidden)
        redirect_to login_path
        return
      end
      @device = Device.new(device_params)
      @device.owner = current_user
      if @device.valid?
        @device.save
        flash[:success] = I18n.t(:new_device_success)
        redirect_to ui_device_path(@device.id)
      else
        flash[:alert] = I18n.t(:new_device_failure)
        render :new, status: :unprocessable_entity
      end
    end

    def upload
      find_device!
      return unless authorize_device! :upload?, :upload_device_forbidden
      @title = I18n.t(:upload_device_title)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@device.owner, current_user)), ui_user_path(@device.owner.username)],
        [I18n.t(:show_device_title, name: @device.name), ui_device_path(@device.id)],
        [@title, download_ui_device_path(@device.id)]
      )
    end

    def upload_readings
      find_device!
      return unless authorize_device! :upload?, :upload_device_forbidden
      params[:data_files].each do |file|
        CSVUploadJob.perform_later(@device.id, file.read)
      end
      flash[:success] = I18n.t(:upload_device_success)
      redirect_to ui_device_path(@device.id)

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
        :hardware_version_override,
        :mac_address,
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
