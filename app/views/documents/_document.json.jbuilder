json.extract! document, :id, :name, :size, :version, :created_at, :updated_at
json.url document_url(document, format: :json)
