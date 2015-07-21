class AddLegacyApiKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :legacy_api_key, :string
    User.reset_column_information
    User.all.each do |u|
      u.update_attribute(:legacy_api_key, Digest::SHA1.hexdigest("#{SecureRandom.uuid}#{rand(1000)}".split("").shuffle.join) )
    end
    change_column :users, :legacy_api_key, :string, null: false
    add_index :users, :legacy_api_key, unique: true
  end
end
