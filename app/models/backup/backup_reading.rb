# == Schema Information
#
# Table name: backup_readings
#
#  id         :integer          not null, primary key
#  data       :jsonb
#  mac        :string
#  version    :string
#  ip         :string
#  stored     :boolean
#  created_at :datetime
#

# This class will be removed, it's currently being used to ensure that
# all reading are stored, whether or not they are valid.

class BackupReading < ActiveRecord::Base
end
