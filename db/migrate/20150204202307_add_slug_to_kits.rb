class AddSlugToKits < ActiveRecord::Migration
  def change
    add_column :kits, :slug, :string
    add_index :kits, :slug
  end
end
