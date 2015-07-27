class AddKeyToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :key, :string
  end
end
