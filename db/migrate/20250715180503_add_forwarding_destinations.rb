class AddForwardingDestinations < ActiveRecord::Migration[6.1]
  def change
    create_table :forwarding_destinations do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :forwarding_destinations, :name, unique: true

    change_table :devices do |t|
      t.belongs_to :forwarding_destination, index: true, null: true, foreign_key: true
    end
  end
end
