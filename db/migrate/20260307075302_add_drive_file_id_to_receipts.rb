class AddDriveFileIdToReceipts < ActiveRecord::Migration[8.1]
  def change
    add_column :receipts, :drive_file_id, :string
  end
end
