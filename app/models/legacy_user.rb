class LegacyUser < MySQL
  self.table_name = 'users'
  has_many :devices, class_name: 'LegacyDevice', foreign_key: 'user_id'

  def as_json
    hash = {}
    cols = %w(id username city country website email created role)
    cols.map{ |c| hash[c] = self[c].to_s }
    hash['devices'] = self.devices
    hash
  end

end
