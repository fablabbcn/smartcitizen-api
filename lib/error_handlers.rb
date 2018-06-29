module ErrorHandlers

  extend ActiveSupport::Concern

  included do

    # rescue_from RuntimeError do |exception|
    #   render json: {
    #     id: "internal_server_error",
    #     message: "Internal Server Error",
    #     errors: "",
    #     url: ""
    #   }, status: 500
    # end

    rescue_from Pundit::NotAuthorizedError do |exception|
      render json: { id: "forbidden", message: "You do not have the access permissions to do this", url: "", errors: "" }, status: :forbidden
    end

    rescue_from ActionController::ParameterMissing do |exception|
      render json: { id: "parameter_missing", message: exception.message, url: "", errors: "" }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: { id: "record_not_found", message: exception.message, url: "", errors: "" }, status: :not_found
    end

    rescue_from Smartcitizen::Unauthorized do |exception|
      render json: { id: "unauthorized", message: exception.message, url: "https://developer.smartcitizen.me/#authentication", errors: "" }, status: :unauthorized
    end

    rescue_from Smartcitizen::UnprocessableEntity do |exception|
      render json: { id: "unprocessable_entity", message: "Unprocessable Entity", errors: exception.message, url: "" }, status: :unprocessable_entity
    end

    # keeping it DRY, see errors_controller
    # rescue_from ActionController::RoutingError do |exception|
    #   render json: { id: "not_found", "message": 'Endpoint not found', "url": "", errors: "" }, status: :not_found
    # end

  end

end
