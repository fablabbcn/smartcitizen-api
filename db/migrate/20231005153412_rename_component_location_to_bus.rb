class RenameComponentLocationToBus < ActiveRecord::Migration[6.1]
  def change
    rename_column :components, :location, :bus
  end
end
