module Presenters
  class BasePresenter

    def default_options
      {}
    end

    def exposed_fields
      []
    end

    def initialize(model, current_user=nil, render_context=nil, options={})
      @model = model
      @current_user = current_user
      @render_context = render_context
      @options = self.default_options.merge(options)
    end

    def as_json(_opts=nil)
      self.exposed_fields.inject({}) { |hash, field|
        value = self.send(field)
        value.nil? ? hash : hash.merge(field => value)
      }
    end

    def method_missing(method, *args, &block)
      if self.exposed_fields.include?(method)
        model.public_send(method, *args, &block)
      else
        super
      end
    end

    def present(other_model, options={})
      Presenters.present(other_model, current_user, render_context, options)
    end

    private

    attr_reader :model, :current_user, :options, :render_context
  end
end
