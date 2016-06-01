class AddReverseEquationToComponents < ActiveRecord::Migration
  def change
    add_column :components, :reverse_equation, :text
  end
end
