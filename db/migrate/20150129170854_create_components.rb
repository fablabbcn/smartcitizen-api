class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.belongs_to :board, polymorphic: true, index: true
      t.belongs_to :sensor, index: true

      t.timestamps null: false
    end
    add_foreign_key :components, :sensors
  end
end
