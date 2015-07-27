class AddUuidsToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
  end
end
