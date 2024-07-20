module V0
  class ExperimentsController < ApplicationController

    before_action :check_if_authorized!, only: [:create, :update, :destroy]

    def index
      raise_ransack_errors_as_bad_request do
        @q = Experiment.ransack(params[:q])
        @q.sorts = 'id asc' if @q.sorts.empty?
        @experiments = @q.result(distinct: true)
        @experiments = paginate @experiments
      end
    end

    def show
      @experiment = Experiment.find(params[:id])
      authorize @experiment
    end

    def create
      @experiment = Experiment.new(experiment_params)
      @experiment.owner ||= current_user
      authorize @experiment
      if @experiment.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @experiment.errors
      end
    end

    def update
      @experiment = Experiment.find(params[:id])
      authorize @experiment
      if @experiment.update(experiment_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @experiment.errors
      end
    end

    def destroy
      @experiment = Experiment.find(params[:id])
      authorize @experiment
      if @experiment.destroy!
        render json: {message: 'OK'}, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @experiment.errors
      end
    end

    private

    def experiment_params
      params.permit(
        :name, :description, :active, :is_test, :starts_at, :ends_at, device_ids: []
      )
    end
  end
end
