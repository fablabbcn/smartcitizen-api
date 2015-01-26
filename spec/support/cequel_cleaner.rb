# https://github.com/cequel/cequel/issues/13#issuecomment-50109486

RSpec.configure do |config|

  records = []

  config.before :suite do
    Cequel::Record.descendants.each do |klass|
      klass.after_create {|r| records << r }
    end
  end

  config.after :each do
    records.each(&:destroy)
    records.clear
  end

  def clean_cequel!
    Cequel::Record.descendants.each { |klass| Cequel::Record.connection.schema.truncate_table(klass.table_name) }
  end

  config.before :suite do
    clean_cequel!
  end

  config.after :suite do
    clean_cequel!
  end

end
