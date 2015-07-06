require 'net/http'
# require 'cgi'

# require 'open-uri'
require 'uri'

module V0
  class KReadingsController < ApplicationController

  skip_after_action :verify_authorized

    def index
      %w(rollup sensor_id function).each do |param|
        raise ActionController::ParameterMissing.new("param not found: #{param}") unless params[param]
      end
      render json: Kairos.query(params)
    end

  end
end
