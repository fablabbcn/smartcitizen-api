class AddStateToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :state, :string
    add_index :devices, :state

    Device.all.each do |d|
      d.update_column(:state, d.soft_state)
    end

  end
end
