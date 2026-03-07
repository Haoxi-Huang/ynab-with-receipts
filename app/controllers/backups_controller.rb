class BackupsController < ApplicationController
  def create
    receipt = current_user.receipts.find(params[:receipt_id])

    unless receipt.linked?
      redirect_to receipt, alert: "Only linked receipts can be backed up."
      return
    end

    if receipt.backed_up?
      redirect_to receipt, notice: "Already backed up."
      return
    end

    drive = GoogleDriveService.new(current_user)
    blob = receipt.image.blob

    blob.open do |tempfile|
      drive_file_id = drive.upload_file(receipt.drive_filename, tempfile, blob.content_type)
      receipt.update!(drive_file_id: drive_file_id)
    end

    redirect_to receipt, notice: "Backed up to Google Drive."
  rescue GoogleDriveService::DriveError => e
    redirect_to receipt, alert: "Backup failed: #{e.message}"
  end

  def bulk
    receipts = current_user.receipts.linked.where(drive_file_id: nil).with_attached_image
    count = 0

    drive = GoogleDriveService.new(current_user)

    receipts.find_each do |receipt|
      next unless receipt.image.attached?

      blob = receipt.image.blob

      blob.open do |tempfile|
        drive_file_id = drive.upload_file(receipt.drive_filename, tempfile, blob.content_type)
        receipt.update!(drive_file_id: drive_file_id)
        count += 1
      end
    end

    redirect_to receipts_path, notice: "Backed up #{count} receipt#{'s' unless count == 1} to Google Drive."
  rescue GoogleDriveService::DriveError => e
    redirect_to receipts_path, alert: "Bulk backup failed: #{e.message}"
  end
end
