json.array! @folders do |folder|
  json.partial! folder, locals: {folder: folder}
  json.contents folder.contents(true)
end