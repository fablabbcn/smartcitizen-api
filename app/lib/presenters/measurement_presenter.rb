module Presenters
  class MeasurementPresenter < BasePresenter

    alias_method :measurement, :model

    def exposed_fields
      %i{id name description unit uuid definition}
    end
  end
end
