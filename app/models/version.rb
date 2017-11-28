require 's3_object'
class Version < ApplicationRecord
  belongs_to :document
  belongs_to :user
  mount_uploader :upfile, UpfileUploader

  def access_url
    temp = S3Representation.new(upfile.path)
    temp.get_presigned_url
  end
end
