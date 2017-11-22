json.partial! @folder, locals: {folder: @folder}
json.contents @folder.contents(true)