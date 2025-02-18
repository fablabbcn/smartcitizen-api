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
      @breadcrumbs ||= []
    end

    def goto_or(url)
      params[:goto].present? ? params[:goto] : url
    end

    helper_method :breadcrumbs
  end
end
