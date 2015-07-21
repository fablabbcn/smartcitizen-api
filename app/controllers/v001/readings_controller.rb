module V001
  class ReadingsController < ApplicationController

    def index
      # ?from_date=:from&to_date=:to&group_by=:range
      @readings = Reading.all
    end

  end
end
