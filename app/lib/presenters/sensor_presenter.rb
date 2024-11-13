module Presenters
  class SensorPresenter < BasePresenter

    alias_method :sensor, :model

    def exposed_fields
      %i{id parent_id name description unit created_at updated_at uuid datasheet unit_definition measurement tags}
    end

    def measurement
      present(sensor.measurement)
    end
  end
end
