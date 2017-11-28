class DocumentDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers
  delegate_all
  decorates_finders

  def parent_folder_id
    super.nil? ? -1 : super
  end

  def parent_folder
    object.parent_folder
  end

  def to_simple_object(api=false)
    if api
      {id: id, type: 0, name: name, url: url(api)}
    else
      {id: id, type: 0, name: name, url: url(api), created_at: object.created_at, updated_at: object.updated_at}
    end
  end

  def url(api=false)
    if api
      URI.join($root_url,api_v1_document_path(self)).to_s
    else
      URI.join($root_url, document_path(self)).to_s
    end
  end
end