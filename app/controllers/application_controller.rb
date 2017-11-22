class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_root_url

  def set_root_url
    $root_url = root_url
  end

  def new_session_path(scope)
    new_user_session_path
  end
end
