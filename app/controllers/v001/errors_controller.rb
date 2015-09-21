module V001
  class ErrorsController < ActionController::API

    def not_found
      render json: { error: "invalid endpoint" }, status: :not_found
    end

    def exception
      render json: {
        id: "internal_server_error",
        message: "Internal Server Error",
        errors: nil,
        url: nil
      }, status: 500
    end

  end
end
