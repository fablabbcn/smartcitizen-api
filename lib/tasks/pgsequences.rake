namespace :pgsequences do
  desc "Reset all Postgres sequences"
  task :reset => :environment do
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
      puts "Reset pk sequence on table: #{t}"
    end
  end
end
