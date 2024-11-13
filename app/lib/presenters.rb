module Presenters
  # This is work in progress we're releasing early so
  # that it can be used in forwarding to send the current
  # values as they're received.
  # TODO: add presenter tests
  # use in appropriate views, delete unneeded code in models and views.
  PRESENTERS = {
    Device => Presenters::DevicePresenter,
    User => Presenters::UserPresenter,
    Component => Presenters::ComponentPresenter,
    Sensor => Presenters::SensorPresenter,
    Measurement => Presenters::MeasurementPresenter,
  }

  def self.present(model_or_collection, user, render_context, options={})
      if model_or_collection.is_a?(Enumerable)
        model_or_collection.map { |model| present(model, user, render_context, options) }
      else
        PRESENTERS[model_or_collection.class]&.new(
          model_or_collection, user, render_context, options
        ).as_json
      end
  end
end
