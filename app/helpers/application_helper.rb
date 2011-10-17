module ApplicationHelper
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
    url = Pollit::Application.config.instedd_theme_url rescue "http://theme.instedd.org.s3.amazonaws.com/"
    URI.join url, path
  end

  def file_form_for(record, options={}, &proc)
    options.merge!(:method => :post, :html => {:multipart => true})
    form_for(record, options, &proc)
  end
end
