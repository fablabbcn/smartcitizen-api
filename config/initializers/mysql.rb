require 'active_record'

class MySQL < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
    :adapter  => 'mysql',
    :database => ENV['mysql_database'],
    :host     => ENV['mysql_host'],
    :username => ENV['mysql_username'],
    :password => ENV['mysql_password'],
    :encoding => 'utf8',
    :collation => 'utf8_general_ci'
  )
end
