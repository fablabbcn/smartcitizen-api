class DeviceIdentifier < ActiveRecord::Base
  belongs_to :device

  validates_presence_of :device, :namespace, :identifier
  validates_inclusion_of :is_archived, in: [false, true]
  validates_uniqueness_of :identifier, scope: %i[device namespace is_archived]

  def self.archive_all(namespace, identifier)
    where(namespace: namespace, identifier: identifier).each(&:archive!)
  end

  def archive!
    self.is_archived = true
    save!
  end

  def unarchive!
    self.is_archived = false
    save!
  end
end
