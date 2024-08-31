module V0
  class ApplicationController < ::ApplicationController

    before_action :prepend_view_paths

    private

    def prepend_view_paths
      # is this still necessary?
      prepend_view_path "app/views/v0"
    end
  end
end
