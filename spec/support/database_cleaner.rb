require 'database_cleaner'

RSpec.configure do |config|

  records = []

  # def clean_cequel!
  #   Cequel::Record.descendants.each { |klass| Cequel::Record.connection.schema.truncate_table(klass.table_name) }
  # end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # Cequel::Record.descendants.each do |klass|
    #   klass.after_create {|r| records << r }
    # end
    # clean_cequel!
  end

  # config.after(:suite) do
  #   clean_cequel!
  # end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    records.each(&:destroy)
    records.clear
  end

end
