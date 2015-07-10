require 'net/http'
# require 'cgi'

# require 'open-uri'
require 'uri'

module V0
  class KReadingsController < ApplicationController

    skip_after_action :verify_authorized

    def index
      missing_params = []
      %w(rollup sensor_id function).each do |param|
        missing_params << param unless params[param]
      end
      if missing_params.any?
        raise ActionController::ParameterMissing.new(missing_params.to_sentence)
      else
        render json: Kairos.query(params)
      end
    end

  end
end
