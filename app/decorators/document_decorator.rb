class DocumentDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers
  delegate_all
  decorates_finders

  def to_simple_object(api=false)
    {id: id, type: 1, name: name, url: url(api)}
  end

  def url(api=false)
    if api
      URI.join($root_url,api_v1_document_path(self)).to_s
    else
      URI.join($root_url, document_path(self)).to_s
    end
  end
end