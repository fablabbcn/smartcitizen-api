namespace :postgres do
  desc 'Resets Postgres auto-increment ID column sequences to fix duplicate ID errors'
  task :reset_sequences => :environment do
    Rails.application.eager_load!

    ActiveRecord::Base.connection.tables.each do |model|
      begin
        ActiveRecord::Base.connection.reset_pk_sequence!(model)
        puts "reset #{model} sequence"
      rescue => e
        Rails.logger.error "Error resetting #{model} sequence: #{e.class.name}/#{e.message}"
      end
    end
  end
end
