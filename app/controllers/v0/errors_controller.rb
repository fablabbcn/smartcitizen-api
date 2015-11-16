module V0
  class ErrorsController < ApplicationController

    skip_after_action :verify_authorized

    def not_found
      render json: {
        id: "not_found",
        message: "Endpoint not found",
        errors: nil,
        url: nil
      }, status: :not_found
    end

    def exception
      render json: {
        id: "internal_server_error",
        message: "Internal Server Error",
        errors: nil,
        url: nil
      }, status: 500
    end

    def test_error
      raise "test error"
    end

  end
end
