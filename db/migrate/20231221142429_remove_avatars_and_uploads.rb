class RemoveAvatarsAndUploads < ActiveRecord::Migration[6.1]
  def change
    drop_table :uploads
    remove_column :users, :avatar_url
  end
end
