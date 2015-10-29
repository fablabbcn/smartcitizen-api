class AddCsvExportRequestedAtToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :csv_export_requested_at, :datetime
  end
end
