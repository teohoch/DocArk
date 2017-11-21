class Folder < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  has_many :folders, class_name: 'Folder', foreign_key: 'parent_folder_id'

  def full_path
    if parent_folder.nil?
      "/#{name}"
    else
      "#{parent_folder.full_path}/#{name}"
    end
  end

  def to_simple_object(api=false)
    {id: id, type: 1, name: name, url: url(api)}
  end

  def url(api=false)
    if api
      "/api/v1/folders/#{id}"
    else
      folder_path(self)
    end
  end

  def contents
    folders.map(&:to_simple_object)
  end
end
