module ErrorHandlers

  extend ActiveSupport::Concern

  included do

    rescue_from Pundit::NotAuthorizedError do |exception|
      render json: { id: "forbidden", message: "You do not have the access permissions to do this", url: nil, errors: nil }, status: :forbidden
    end

    rescue_from ActionController::ParameterMissing do |exception|
      render json: { id: "parameter_missing", message: exception.message, url: nil, errors: nil }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |exception=nil|
      render json: { id: "record_not_found", message: exception.try(:message), url: nil, errors: nil }, status: :not_found
    end

    rescue_from Smartcitizen::NotAuthorized do |exception|
      # render json: exception, status: :unauthorized
      render json: { id: "not_authorized", message: exception.message, url: nil, errors: nil }, status: :unauthorized
    end

    rescue_from Smartcitizen::UnprocessableEntity do |exception|
      render json: { id: "unprocessable_entity", message: "Unprocessable Entity", errors: exception.message, url: nil }, status: :unprocessable_entity
    end

    rescue_from ActionController::RoutingError do |exception|
      render json: { id: "not_found", "message": 'Endpoint not found', "url": nil, errors: nil }, status: :not_found
    end

  end

end
