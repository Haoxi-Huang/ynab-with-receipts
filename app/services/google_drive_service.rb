require "google/apis/drive_v3"
require "signet/oauth_2/client"

class GoogleDriveService
  FOLDER_NAME = "Receipts for YNAB"
  FOLDER_MIME = "application/vnd.google-apps.folder"

  class DriveError < StandardError; end

  def initialize(user)
    @user = user
    @drive = Google::Apis::DriveV3::DriveService.new
    @drive.authorization = build_credentials
  end

  def upload_file(filename, io, content_type)
    folder_id = find_or_create_folder

    metadata = Google::Apis::DriveV3::File.new(
      name: filename,
      parents: [folder_id]
    )

    result = @drive.create_file(
      metadata,
      upload_source: io,
      content_type: content_type,
      fields: "id"
    )

    result.id
  rescue Google::Apis::Error => e
    raise DriveError, "Failed to upload to Drive: #{e.message}"
  end

  def delete_file(drive_file_id)
    @drive.delete_file(drive_file_id)
  rescue Google::Apis::ClientError => e
    raise DriveError, "Failed to delete from Drive: #{e.message}" unless e.status_code == 404
  rescue Google::Apis::Error => e
    raise DriveError, "Failed to delete from Drive: #{e.message}"
  end

  private

  def build_credentials
    access_token = @user.refresh_google_token!

    Signet::OAuth2::Client.new(
      access_token: access_token
    )
  end

  def find_or_create_folder
    query = "name = '#{FOLDER_NAME}' and mimeType = '#{FOLDER_MIME}' and trashed = false"
    results = @drive.list_files(q: query, spaces: "drive", fields: "files(id)")

    if results.files.any?
      results.files.first.id
    else
      folder = Google::Apis::DriveV3::File.new(
        name: FOLDER_NAME,
        mime_type: FOLDER_MIME
      )
      result = @drive.create_file(folder, fields: "id")
      result.id
    end
  rescue Google::Apis::Error => e
    raise DriveError, "Failed to access Drive folder: #{e.message}"
  end
end
