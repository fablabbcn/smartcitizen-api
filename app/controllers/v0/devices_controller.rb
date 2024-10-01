module V0
  class DevicesController < ApplicationController
    before_action :check_if_authorized!, only: [:create]
    after_action :verify_authorized,
      except: [:index, :world_map, :fresh_world_map]

    def show
      @device = Device.includes(
        :owner,:tags, {sensors: :measurement}).find(params[:id])
      authorize @device
      @device
    end

    def index
      raise_ransack_errors_as_bad_request do
        @q = policy_scope(Device)
          .includes(:owner, :tags, :components, {sensors: :measurement})
          .ransack(params[:q], auth_object: (current_user&.is_admin? ? :admin : nil))

        # We are here customly adding multiple tags into the Ransack query.
        # Ransack supports this, but how do we add multiple tag names in URL string? Which separator to use?
        # See Issue #186 https://github.com/fablabbcn/smartcitizen-api/issues/186
        # If we figure it out, we can remove the next 3 lines, but remember to document in:
        # https://developer.smartcitizen.me/#basic-searching
        if params[:with_tags]
          @q.tags_name_in = params[:with_tags].split('|')
        end

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
      end
    end

    def update
      @device = Device.find(params[:id])
      authorize @device
      if @device.update(device_params)
        render :show, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @device.errors
      end
    end

    def create
      @device = current_user.devices.build(device_params)
      authorize @device
      if @device.save
        render :show, status: :created
      else
        raise Smartcitizen::UnprocessableEntity.new @device.errors
      end
    end

    def destroy
      @device = Device.find(params[:id])
      authorize @device
      if @device.archive!
        render json: {message: 'OK'}, status: :ok
      else
        raise Smartcitizen::UnprocessableEntity.new @device.errors
      end
    end

    # debug method, must be refactored
    def fresh_world_map
    end

    def world_map
    end

private

    def device_params
      params_to_permit = [
        :name,
        :description,
        :hardware_name_override,
        :hardware_version_override,
        :hardware_type_override,
        :hardware_slug_override,
        :mac_address,
        :latitude,
        :longitude,
        :elevation,
        :device_token,
        :notify_low_battery,
        :notify_stopped_publishing,
        :precise_location,
        :exposure,
        :meta,
        :user_tags,
        :is_private,
        postprocessing_attributes: [:blueprint_url, :hardware_url, :latest_postprocessing, :meta, :forwarding_params],
      ]

      # Researchers + Admins can update is_test and enable_forwarding
      if current_user.is_admin_or_researcher?
        params_to_permit.push(:is_test, :enable_forwarding)
      end

      params.permit(
        params_to_permit
      )
    end

  end
end
