module Ui
  class ExperimentsController < ApplicationController
    def show
      find_experiment!
      return unless authorize_experiment! :show?, :show_experiment_forbidden
      @title = I18n.t(:show_experiment_title, name: @experiment.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@experiment.owner, current_user)), ui_user_path(@experiment.owner.username)],
        [@title, ui_experiment_path(@experiment.id)]
      )
      render "show", layout: "base"
    end

    def readings
      find_experiment!
      return unless authorize_experiment! :show?, :show_experiment_forbidden
      return unless find_measurement!
      @title = I18n.t(:readings_experiment_title, name: @experiment.name)
      add_breadcrumbs(
        [I18n.t(:show_user_title, owner: helpers.possessive(@experiment.owner, current_user)), ui_user_path(@experiment.owner.username)],
        [I18n.t(:show_experiment_title, name: @experiment.name), ui_experiment_path(@experiment.id)],
        [@title, readings_ui_experiment_path(@experiment.id)]
      )
      render "readings", layout: "base"
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
  end
end
