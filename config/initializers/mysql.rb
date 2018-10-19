require 'active_record'

class MySQL < ActiveRecord::Base
  self.abstract_class = true
end
