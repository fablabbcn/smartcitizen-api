class LegacyUser < MySQL
  self.table_name = 'users'
  has_many :devices, class_name: 'LegacyDevice', foreign_key: 'user_id'

  def as_json
    hash = {}
    cols = %w(id username city country website email created role)
    cols.map{ |c| hash[c] = self[c].to_s }
    hash['created'] = self.created.to_s.gsub(' UTC', '')
    hash['devices'] = self.devices.map{|d| d.as_json(false) }
    hash
  end

end
