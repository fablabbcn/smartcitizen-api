class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :type
      t.string :original_filename
      t.jsonb :metadata

      t.timestamps null: false
    end
    add_index :uploads, :type
  end
end
