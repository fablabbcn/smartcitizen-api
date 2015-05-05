class ErrorsController < ActionController::API

  def not_found
    render json: { id: "not_found", message: 'Endpoint not found', url: nil, errors: nil }, status: :not_found
  end

  def exception
    # render :json => {:id => "internal_server_error", :message => 'Internal Server Error'}.to_json, :status => 500
    render json: { id: "internal_server_error", message: 'Internal Server Error', url: nil, errors: nil }, status: 500
  end

  def catch_404
    # raise ActionController::RoutingError.new(params[:path])
    render json: { id: "not_found", message: 'Endpoint not found', url: nil, errors: nil }, status: :not_found
  end

end
