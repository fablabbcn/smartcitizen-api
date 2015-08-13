class LegacyUser < MySQL
  self.table_name = 'users'
  has_many :devices, class_name: 'LegacyDevice', foreign_key: 'user_id'
end
