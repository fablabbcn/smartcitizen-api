class AddPostProcessingInfoToDevice < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :postprocessing_info, :jsonb
  end
end
