class Version < ApplicationRecord
  belongs_to :document
  belongs_to :user
  mount_uploader :upfile, UpfileUploader

  before_destroy :destroy_cloud

  private

  def destroy_cloud
    # TODO Implement Function that deletes a certain version of a file from the cloud
    sleep(0.1)
  end
end
