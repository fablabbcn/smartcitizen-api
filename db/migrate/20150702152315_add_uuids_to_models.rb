class AddUuidsToModels < ActiveRecord::Migration
  def change
    [:components, :devices, :kits, :measurements, :sensors, :users].each do |model|
      add_column model, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
    end
  end
end
