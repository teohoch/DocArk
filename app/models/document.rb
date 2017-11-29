class Document < ApplicationRecord
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  has_many :versions, dependent: :destroy

  validates_uniqueness_of :name, :scope => [:parent_folder_id, :created_by_id]
  validates :created_by, presence: true
  validates :updated_by, presence: true
  validates :name, presence: true, allow_blank: false
  validate :parent_folder_ownership

  scope :in_root, -> () {where(parent_folder: nil)}
  scope :child_of, -> (parent_id=nil) {where(parent_folder_id: parent_id)}
  scope :is_owner, -> (owner) {where(created_by: owner)}
  scope :name_ilike, -> (name) { where('name ilike any ( array[?] )', name.map {|val| "%#{val}%"} ) }

  attr_accessor :upfile

  after_initialize do
    @version = versions.count.zero? ? nil : latest_version.version
  end

  before_destroy :destroy_versions
  def access_url
    current_version.access_url
  end

  def expiration_date
    Time.now + 1.hour
  end

  def version
    if @version.nil?
      @version = versions.count.zero? ? nil : latest_version.version
    end
    @version
  end

  def version=(ver)
    unless available_versions.include? ver
      raise ArgumentError, 'The specified version does\' exist!'
    end
    @version = ver
  end

  def size
    current_version.size
  end

  def available_versions
    versions.pluck(:version)
  end

  def full_path
    parent_folder.nil? ? "/#{name}" : "#{parent_folder.full_path}/#{name}"
  end

  def parent_folder_ownership
    unless parent_folder.nil? or parent_folder.created_by == created_by
      errors[:parent_folder_ownership] << 'You don\'t have access to the parent folder.'
    end
  end

  def current_version
    versions.where(version: version).first
  end

  private

  def destroy_versions
    versions.destroy_all
  end



  def latest_version
    versions.where(current: true).order(version: :desc).first
  end
end
