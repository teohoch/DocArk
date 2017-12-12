json.array! @documents do |document|
  json.partial! document, locals: {document: document}
end