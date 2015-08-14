module V001
  class ApplicationController < ActionController::API
    # include PrettyJSON

    before_action :check_api_key

private

    def current_user
      @current_user = LegacyUser.find_by(api_key: params[:api_key])
    end
    helper_method :current_user

    def check_api_key
      unless current_user
        render json: {error: "invalid API KEY"}, status: :unauthorized
      end
    end

  end
end
