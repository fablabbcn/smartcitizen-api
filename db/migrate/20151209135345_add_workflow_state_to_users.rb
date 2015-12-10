class AddWorkflowStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :workflow_state, :string
    add_index :users, :workflow_state
    User.update_all(workflow_state: 'active')
  end
end
