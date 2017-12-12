require 's3_object'
class Version < ApplicationRecord
  belongs_to :document
  belongs_to :user
  mount_uploader :upfile, UpfileUploader
  validates :upfile, file_size: { less_than: 5.megabytes }

  def access_url
    temp = S3Representation.new(upfile.path)
    temp.get_presigned_url
  end
end
