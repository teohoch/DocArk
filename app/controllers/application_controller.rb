class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception


  before_action :set_root_url

  def set_root_url
    $root_url = root_url
  end

  def new_session_path(scope)
    new_user_session_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, :flash => { :error => exception.message} }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end
end
