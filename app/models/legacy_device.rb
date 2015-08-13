class LegacyDevice < MySQL

  self.table_name = 'devices'
  belongs_to :user, class_name: 'LegacyUser'

  def as_json
    hash = {}
    cols = %w(id title description location city country exposure elevation title location geo_lat geo_long created last_insert_datetime)
    cols.map{ |c| hash[c] = self[c].to_s }
    hash
  end

end

