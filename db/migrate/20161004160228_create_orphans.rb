class CreateOrphans < ActiveRecord::Migration
  def change
    create_table :orphans do |t|
      t.string  :session_key, index: true
      t.json    :data
      t.timestamps null: false
    end
  end
end
