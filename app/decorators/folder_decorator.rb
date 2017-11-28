class FolderDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers
  delegate_all
  decorates_finders
  decorates_association :folders
  decorates_association :documents

  def parent_folder_id
    super.nil? ? -1 : super
  end

  def parent_folder
    object.parent_folder
  end


  def to_simple_object(api=false)
    if api
      {id: id, type: 1, name: name, url: url(api)}
    else
      {id: id, type: 1, name: name, url: url(api), created_at: object.created_at, updated_at: object.updated_at}
    end
  end



  def url(api=false)
    if api
      URI.join($root_url,api_v1_folder_path(self)).to_s
    else
      URI.join($root_url, folder_path(self)).to_s
    end
  end

  def contents(api=false)
    folders.map{|x|x.to_simple_object(api)} + documents.map{|x|x.to_simple_object(api)}
  end
end