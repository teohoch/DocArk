class Document < ApplicationRecord
  belongs_to :parent_folder, class_name: 'Folder', optional: true
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  has_many :versions

  validates_uniqueness_of :name, :scope => [:parent_folder_id, :created_by_id]
  validates :created_by, presence: true
  validates :updated_by, presence: true
  validate :parent_folder_ownership

  scope :in_root, -> () {where(parent_folder: nil)}
  scope :child_of, -> (parent_id=nil) {where(parent_folder_id: parent_id)}
  scope :is_owner, -> (owner) {where(created_by: owner)}
  scope :name_ilike, -> (name) { where('name ilike any ( array[?] )', name.map {|val| "%#{val}%"} ) }

  after_initialize do
    @version = versions.blank? ? nil : latest_version.version
  end

  before_destroy :destroy_versions

  def access_url
    generate_access_url
    current_version.access_url
  end

  def expiration_date
    generate_access_url
    current_version.expiration_date
  end

  def version
    if @version.nil?
      @version = @version.blank? ? nil : latest_version.version
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
    unless parent_folder.created_by == created_by
      errors[:parent_folder_ownership] << 'You don\'t have access to the parent folder.'
    end
  end

  private

  def destroy_versions
    versions.destroy_all
  end

  def current_version
    versions.where(version: @version).first
  end

  def latest_version
    versions.where(current: true).order(version: :desc).first
  end

  def generate_access_url
    if @access_url.nil?
      url_asigner
    elsif DateTime.now > @expiration_date
      url_asigner
    end
  end

  def url_asigner
    current_version.update(url_generator)
  end

  def url_generator
    # TODO Implement function that generates url
    {access_url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Lockheed_SR-71_Blackbird.jpg/1200px-Lockheed_SR-71_Blackbird.jpg',expiration_date: Faker::Time.forward(1)}
  end

end
