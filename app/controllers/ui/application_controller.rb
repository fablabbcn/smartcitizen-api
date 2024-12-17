module Ui
  class ApplicationController < ActionController::Base
    layout "application"
    include SharedControllerMethods

    private

    def add_breadcrumbs(*crumbs)
      crumbs.each do |crumb|
        add_breadcrumb(*crumb)
      end
    end

    def add_breadcrumb(label, url=nil)
      breadcrumbs << Breadcrumb.new(breadcrumbs, label, url)
    end

    def breadcrumbs
      unless @breadcrumbs
        @breadcrumbs = []
        @breadcrumbs << Breadcrumb.new(@breadcrumbs, t(:root_breadcrumb))
      end
      return @breadcrumbs
    end

    helper_method :breadcrumbs
  end
end
