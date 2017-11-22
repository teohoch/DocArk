class Document < ApplicationRecord
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  has_many :versions

  validates_uniqueness_of :name, :scope => [:parent_folder_id, :created_by_id]
  validates :created_by, presence: true
  validates :updated_by, presence: true
  validates :parent_folder, presence: true
  validate :parent_folder_ownership


  def parent_folder_ownership
    unless parent_folder.created_by == created_by
      errors[:parent_folder_ownership] << 'You don\'t have access to the parent folder.'
    end
  end
end
