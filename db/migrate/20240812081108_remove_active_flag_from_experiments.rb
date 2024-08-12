class RemoveActiveFlagFromExperiments < ActiveRecord::Migration[6.1]
  def change
    remove_column :experiments, :active, :boolean
  end
end
