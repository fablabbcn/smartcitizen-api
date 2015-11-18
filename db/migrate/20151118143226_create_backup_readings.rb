class CreateBackupReadings < ActiveRecord::Migration
  def change
    create_table :backup_readings do |t|
      t.jsonb :data
      t.string :mac
      t.string :version
      t.string :ip
      t.boolean :stored
      t.datetime :created_at
    end
  end
end
