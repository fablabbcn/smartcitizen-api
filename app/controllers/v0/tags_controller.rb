module V0
  class TagsController < ApplicationController

    def index
      @tags = Tag.all
      @tags = paginate @tags
    end

  end
end

