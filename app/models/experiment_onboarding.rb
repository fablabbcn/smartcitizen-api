class ExperimentOnboarding
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :description, :string
  attribute :is_test, :boolean, default: false
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime

  attribute :device_is_private, :boolean, default: false
  attribute :device_precise_location, :boolean, default: false
  attribute :device_notify_low_battery, :boolean, default: false
  attribute :device_notify_stopped_publishing, :boolean, default: false
  attribute :device_enable_forwarding, :boolean, default: false
  attribute :device_hardware_url, :string

  attr_accessor :owner
  attr_accessor :device_tag_ids
  attr_accessor :device_forwarding_destination_id
  attr_accessor :device_postprocessing_attributes

  attr_accessor :experiment
  attr_accessor :devices

  validate :experiment_valid
  validate :at_least_one_device
  validate :all_devices_valid

  def initialize(attrs = {})
    super
    @experiment = Experiment.new(self.experiment_attributes(attrs))
    @devices = attrs.fetch(:devices, {}).values.map { |device_attrs|
      Device.new(self.device_attributes(@experiment, device_attrs, attrs))
    }
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      experiment.save!
      devices.reverse.each(&:save!) # reverse so they show in order later.
      experiment.devices << devices
    end

    true

  rescue ActiveRecord::RecordInvalid  => e
    errors.add(:base, e.message)
    false
  end

  private

  def experiment_attributes(attrs)
    attrs.select { |k, v| k.to_s !~ /^device/ }
  end

  def device_attributes(experiment, device_attrs, experiment_attrs)
    shared_attrs = experiment_attrs.
      select { |k, v| k.to_s =~ /^device_/ || k == :owner }.
      transform_keys { |k, v| k.to_s.sub(/^device_/, "").to_sym }
    return shared_attrs.merge(device_attrs)
  end

  def experiment_valid
    unless experiment.valid?
        experiment.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end
  end

  def all_devices_valid
    devices.each_with_index do |device, i|
        unless device.valid?
          device.errors.each do |error|
            errors.add("devices[#{i}].#{error.attribute}", error.message)
          end
        end
      end
  end

  def at_least_one_device
    errors.add(:devices, "must have at least one device") if devices.empty?
  end
end


