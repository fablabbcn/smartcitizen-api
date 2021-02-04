class CreatePostprocessings < ActiveRecord::Migration[6.0]
  def change
    remove_column :devices, :postprocessing_info, :jsonb

    create_table :postprocessings do |t|
      t.string :blueprint_url
      t.string :hardware_url
      t.belongs_to :device, null: false, foreign_key: true
      t.jsonb :forwarding_params
      t.jsonb :meta
      t.datetime :latest_postprocessing

      t.timestamps
    end
  end
end
