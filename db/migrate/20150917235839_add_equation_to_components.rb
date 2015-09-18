class AddEquationToComponents < ActiveRecord::Migration
  def change
    add_column :components, :equation, :text
  end
end
