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

require 'rails_helper'

RSpec.describe BackupReading, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
