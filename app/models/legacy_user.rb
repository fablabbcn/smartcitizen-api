class LegacyUser < MySQL
  self.table_name = 'users'
  has_many :devices, class_name: 'LegacyDevice', foreign_key: 'user_id'

  def as_json(options={})
    {
      id: self.id,
      username: self.username,
      city: self.city,
      country: self.country,
      website: self.website,
      email: self.email,
      created: self.created,
      role: self.role,
      devices: self.devices
    }
  end

  def as_json
    hash = {}
    cols = %w(id username city country website email created role)
    cols.map{ |c| hash[c] = self[c].to_s }
    hash['devices'] = self.devices
    hash
  end

end
