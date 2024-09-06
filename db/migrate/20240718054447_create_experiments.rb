class CreateExperiments < ActiveRecord::Migration[6.1]
  def change
    create_table :experiments do |t|
      t.string :name, null: false
      t.string :description
      t.belongs_to :owner, index: true
      t.boolean :active, null: false, default: true
      t.boolean :is_test, null: false, default: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end
    add_foreign_key :experiments, :users, column: :owner_id

    create_table :devices_experiments, id: false do |t|
      t.belongs_to :device, index: true
      t.belongs_to :experiment, index: true
    end
    add_foreign_key :devices_experiments, :devices, column: :device_id
    add_foreign_key :devices_experiments, :experiments, column: :experiment_id
  end
end
