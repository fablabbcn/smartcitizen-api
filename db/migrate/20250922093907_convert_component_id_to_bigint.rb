class ConvertComponentIdToBigint < ActiveRecord::Migration[6.1]
  def change
    change_column :components, :id, :bigint
  end
end
