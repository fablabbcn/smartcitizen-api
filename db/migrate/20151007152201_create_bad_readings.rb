class CreateBadReadings < ActiveRecord::Migration
  def change
    create_table :bad_readings do |t|
      t.integer :tags
      t.string :remote_ip
      t.jsonb :data, null: false
      t.datetime :created_at, null: false
    end
  end
end
