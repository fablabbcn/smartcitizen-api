class AddWorkflowStateToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :workflow_state, :string
    add_index :devices, :workflow_state
    Device.reset_column_information
    Device.unscoped.update_all(workflow_state: 'active')
    # Device.all.each do |device|
    #   device.update_attributes(:workflow_state => 'normal')
    # end
  end
end
