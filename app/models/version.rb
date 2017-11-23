class Version < ApplicationRecord
  belongs_to :document
  belongs_to :user
  mount_uploader :upfile, UpfileUploader

end
