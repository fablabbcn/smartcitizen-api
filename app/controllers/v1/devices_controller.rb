module V1
  class DevicesController < ApplicationController
    def show
      @device = Device.includes(
        :owner,:tags, {sensors: :measurement}).find(params[:id])
      authorize @device
      render json: present(@device)
    end

   #TODO Document breaking API change as detailed in https://github.com/fablabbcn/smartcitizen-api/issues/186
    def index
      raise_ransack_errors_as_bad_request do
        @q = policy_scope(Device)
          .includes(:owner, :tags, :components, {sensors: :measurement})
          .ransack(params[:q], auth_object: (current_user&.is_admin? ? :admin : nil))

        @devices = @q.result(distinct: true)

        if params[:near]
          if params[:near] =~ /\A(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)\z/
            @devices = @devices.near(
              params[:near].split(','), (params[:within] || 1000))
          else
            return render json: { id: "bad_request",
              message: "Malformed near parameter",
              url: 'https://developer.smartcitizen.me/#get-all-devices',
              errors: nil }, status: :bad_request
          end
        end
        @devices = paginate(@devices)
        render json: present(@devices)
      end
    end
  end
end
