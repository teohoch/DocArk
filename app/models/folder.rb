class Folder < ApplicationRecord
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :parent_folder, class_name: 'Folder'
  has_many :folders, :class_name => 'Folder', foreign_key: 'parent_folder_id'

end
