module ApplicationHelper
  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

  def render_flash
    rendered = []
    flash.each do |type, messages|
      if messages.is_a? Array
        messages.each do |m|
          rendered << render(:partial => 'layouts/flash_message', :locals => {:type => type, :message => m}) unless m.blank?
        end
      else
        rendered << render(:partial => 'layouts/flash_message', :locals => {:type => type, :message => messages}) unless messages.blank?
      end
    end
    html = rendered.join.squish
    html.html_safe
  end

  def bootstrap_class_for(flash_type)
    {success: 'alert-success', error: 'alert-danger', warning: 'alert-warning', notice: 'alert-info', alert: 'alert-danger'}[flash_type.to_sym]
  end
end
