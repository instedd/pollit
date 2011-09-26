module ApplicationHelper
  def angular_js_include_tag
    raw(content_tag(:script, nil, {
      "ng:autobind" => "", 
      :src => "/assets/angular/angular-0.9.19.min.js"
      }, escape=false))
  end
end
