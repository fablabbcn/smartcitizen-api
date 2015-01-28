class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.belongs_to :owner, index: true, null: false
      t.string :token, null: false
      t.timestamps null: false
    end
    add_index :api_tokens, [:owner_id, :token], unique: true
    add_foreign_key :api_tokens, :users, column: :owner_id
  end
end
