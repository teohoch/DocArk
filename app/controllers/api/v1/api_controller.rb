class Api::V1::APIController < ActionController::Base

  before_action :set_root_url

  def set_root_url
    $root_url = root_url
  end

  def new_session_path(scope)
    new_user_session_path
  end

  def error_creator(error_info)
    case error_info.keys[0]
      when :parent_folder
        {code: 400, message: 'The Parent Folder must be valid.'}
      when :name
        {code: 409, message: 'Conflict - Duplicated Name in the folder.'}
      when :parent_folder_ownership
        {code: 401, message: 'You don\'t have access to the parent folder.'}
      when :contents
        {code: 403, message: 'The Folder you\'re trying to delete has contents!.'}
      else
        {code: 500, message: 'Unknown Error'}
    end
  end

  def error_renderer(error_hash)
    render partial: 'api/v1/error', locals: {:@error => error_hash}, status: error_hash[:code]
  end
end
