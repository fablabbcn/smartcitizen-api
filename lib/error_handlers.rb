module ErrorHandlers

  extend ActiveSupport::Concern

  included do

    rescue_from ActionController::ParameterMissing do |exception|
      render json: {message: exception.message}, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: {message: exception.message}, status: :not_found
    end

    rescue_from Smartcitizen::NotAuthorized do |exception|
      render json: exception, status: :unauthorized
    end

  end

end
