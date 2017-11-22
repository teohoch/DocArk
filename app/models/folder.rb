class Folder < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  has_many :folders, class_name: 'Folder', foreign_key: 'parent_folder_id', inverse_of: :parent_folder
  has_many :documents, class_name: 'Document', foreign_key: 'parent_folder_id', inverse_of: :parent_folder
  validates_uniqueness_of :name, :scope => [:parent_folder_id, :created_by_id]
  validates :created_by, presence: true
  validates :updated_by, presence: true
  validate :parent_folder_ownership

  before_destroy :has_contents?

  scope :in_root, -> () {where(parent_folder: nil)}
  scope :child_of, -> (parent_id=nil) {where(parent_folder_id: parent_id)}
  scope :is_owner, -> (owner) {where(created_by: owner)}
  scope :name_ilike, -> (name) { where('name ilike any ( array[?] )', name.map {|val| "%#{val}%"} ) }

  def full_path
    parent_folder.nil? ? "/#{name}" : "#{parent_folder.full_path}/#{name}"
  end

  private

  def parent_folder_ownership
    unless parent_folder.nil? or parent_folder.created_by == created_by
      errors[:parent_folder_ownership] << 'You don\'t have access to the parent folder.'
    end
  end

  def has_contents?
    unless folders.count.zero? and documents.count.zero?
      errors[:contents] << 'The Folder you\'re trying to delete has contents!.'
    end
    throw(:abort) unless errors.blank?
  end

  def force_delete
    documents.delete_all
    folders.each(&:force_delete)
    self.destroy
  end



end
