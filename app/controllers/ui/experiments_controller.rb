module Ui
  class ExperimentsController < ApplicationController
    def show
      find_experiment!
      return unless authorize_experiment! :show?, :show_experiment_forbidden
      @title = I18n.t(:show_experiment_title, name: @experiment.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner_name), ui_user_path(@experiment.owner.username)],
        [@title, ui_experiment_path(@experiment.id)]
      )
    end

    def readings
      find_experiment!
      return unless authorize_experiment! :show?, :show_experiment_forbidden
      return unless find_measurement!
      @title = I18n.t(:readings_experiment_title, name: @experiment.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner_name), ui_user_path(@experiment.owner.username)],
        [I18n.t(:show_experiment_title, name: @experiment.name), ui_experiment_path(@experiment.id)],
        [I18n.t(:readings_breadcrumb), readings_ui_experiment_path(@experiment.id)]
      )
    end

    def edit
      find_experiment!
      return unless authorize_experiment! :update?, :edit_experiment_forbidden
      @title = I18n.t(:edit_experiment_title, name: @experiment.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner_name), ui_user_path(@experiment.owner.username)],
        [I18n.t(:show_experiment_title, name: @experiment.name), ui_experiment_path(@experiment.id)],
        [I18n.t(:edit_breadcrumb), edit_ui_experiment_path(@experiment.id)]
      )
    end

    def update
      find_experiment!
      return unless authorize_experiment! :update?, :edit_experiment_forbidden
      if @experiment.update(experiment_params)
        flash[:success] = I18n.t(:update_experiment_success)
        redirect_to goto_or(ui_experiment_path(@experiment.id))
      else
        flash[:alert] = I18n.t(:update_experiment_failure)
        render :edit, status: :unprocessable_entity
      end
    end

    def new
      unless current_user
        flash[:alert] = I18n.t(:create_experiment_forbidden)
        redirect_to login_path
        return
      end
      @title = I18n.t(:new_experiment_title)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner_name), ui_user_path(current_user)],
        [@title, new_ui_experiment_path]
      )
      @experiment = Experiment.new(owner: current_user)
    end

    def create
      unless current_user
        flash[:alert] = I18n.t(:create_experiment_forbidden)
        redirect_to login_path
        return
      end
      @experiment = Experiment.new(experiment_params)
      @experiment.owner = current_user
      if @experiment.valid?
        @experiment.save
        flash[:success] = I18n.t(:new_experiment_success)
        redirect_to ui_experiment_path(@experiment.id)
      else
        flash[:alert] = I18n.t(:new_experiment_failure)
        render :new, status: :unprocessable_entity
      end
    end

    def delete
      find_experiment!
      return unless authorize_experiment! :destroy?, :delete_experiment_forbidden
      @title = I18n.t(:delete_experiment_title, name: @experiment.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: owner_name), ui_user_path(@experiment.owner.username)],
        [I18n.t(:show_experiment_title, name: @experiment.name), ui_experiment_path(@experiment.id)],
        [I18n.t(:edit_breadcrumb), edit_ui_experiment_path(@experiment.id)],
        [I18n.t(:delete_breadcrumb), delete_ui_experiment_path(@experiment.id)]
      )
    end

    def destroy
      find_experiment!
      return unless authorize_experiment! :destroy?, :delete_experiment_forbidden
      if @experiment.name != params[:name]
        flash[:alert] = I18n.t(:delete_experiment_wrong_name)
        redirect_to delete_ui_experiment_path(@experiment.id)
        return
      end
      @experiment.destroy!
      flash[:success] = I18n.t(:delete_experiment_success)
      redirect_to ui_user_path(current_user.username)
    end

    private

    def find_experiment!
      @experiment = Experiment.find(params[:id])
    end

    def find_measurement!
      @measurement = params[:measurement_id] && Measurement.find(params[:measurement_id])
      if @measurement
        return @measurement
      else
        measurement = @experiment.all_measurements.first
        redirect_to measurement ? readings_ui_experiment_path(@experiment, measurement_id: measurement.id) : ui_experiment_path(@experiment)
        return nil
      end
    end

    def authorize_experiment!(action, alert)
      return true if authorize? @experiment, action
      flash[:alert] = I18n.t(alert)
      redirect_to current_user ? ui_user_path(current_user.username) : login_path
      return false
    end

    def experiment_params
      params.require(:experiment).permit(
        :name,
        :description,
        :is_test,
        :starts_at,
        :ends_at,
        { :device_ids => [] },
      ).transform_values {|v| v.blank? ? nil : v }
    end

    def owner_name(capitalize=true)
      owner = @experiment&.owner || current_user
      helpers.possessive(owner, current_user, capitalize: capitalize, third_person: true)
    end
  end
end
