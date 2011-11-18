module ApplicationHelper
  
  def image_tag(source, options = {})
    source = File.join(I18n.locale.to_s, source) if options.delete(:localized)
    super(source, options)
  end

  def wizard?
    params[:wizard]
  end

  def angular_js_include_tag
    raw(content_tag(:script, nil, {
      "ng:autobind" => "", 
      :src => "/assets/angular/angular-0.9.19.min.js"
      }, escape=false))
  end

  def instedd_theme_url_for(path)
    url = Pollit::Application.config.theme_url
    URI.join url, path
  end

  def file_form_for(record, options={}, &proc)
    options.merge!(:method => :post, :html => {:multipart => true})
    form_for(record, options, &proc)
  end

  def section title, url, name, active_controllers = [name]
    active = active_controllers.any?{|controller| controller_name == controller.to_s }
    raw "<li class=\"#{active ? "active" : ""}\">#{link_to title, url}</li>"
  end
end
