module V001
  class ApplicationController < ActionController::API

    before_action :check_api_key

private

    def check_api_key
      begin User.find(params[:api_key])
      rescue ActiveRecord::RecordNotFound
        render json: {error: "invalid API KEY"}, status: :unauthorized
      end
    end

  end
end