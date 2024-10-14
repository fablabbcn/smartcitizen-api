class CreateDeviceIngestErrors < ActiveRecord::Migration[6.1]
  def change
    create_table :ingest_errors do |t|
      t.references :device, null: false, foreign_key: true
      t.text :topic
      t.text :message
      t.text :error_class
      t.text :error_message
      t.text :error_trace
      t.timestamps
    end
  end
end
