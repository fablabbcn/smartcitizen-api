module ErrorHandlers

  extend ActiveSupport::Concern

  included do

    rescue_from ActionController::ParameterMissing do |exception|
      render json: { id: "parameter_missing", "message": exception.message, "url": nil }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: { id: "record_not_found", "message": exception.message, "url": nil }, status: :not_found
    end

    rescue_from Smartcitizen::NotAuthorized do |exception|
      # render json: exception, status: :unauthorized
      render json: { id: "not_authorized", message: exception.message, url: nil }, status: :unauthorized
    end

    rescue_from Smartcitizen::UnprocessableEntity do |exception|
      render json: { id: "unprocessable_entity", message: exception.message }, status: :unprocessable_entity
    end

    rescue_from ActionController::RoutingError do |exception|
      render json: { id: "not_found", "message": 'Page not found', "url": nil }, status: :not_found
    end

  end

end
