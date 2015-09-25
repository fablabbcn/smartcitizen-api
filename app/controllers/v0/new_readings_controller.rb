require 'net/http'
require 'uri'

module V0
  class NewReadingsController < ApplicationController

    def index
      check_missing_params("rollup", "sensor_key||sensor_id") # sensor_key or sensor_id
      render json: NewKairos.query(params)
    end

  end
end
