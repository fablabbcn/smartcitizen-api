class AddUuidToTags < ActiveRecord::Migration
  def change
    add_column :tags, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
  end
end
