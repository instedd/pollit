module InsteddAppHelper
  def flash_message
    res = nil
    
    keys = { :notice => 'flash_notice', :error => 'flash_error', :alert => 'flash_error' }
    
    keys.each do |key, value|
      if flash[key]
        res = content_tag :div, :class => "flash #{value}" do
          content_tag :div do
            flash[key]
          end
        end
      end
    end
    
    res
  end
  
  def errors_for(object, options = {})
    if object.errors.any?
       # TODO change on rails 3.1 to ActiveModel::Naming.param_key(object)
      object_name = options[:as].try(:to_s) || ActiveModel::Naming.singular(object)
          
      content_tag :div, :class => "box error_description #{options[:class] || 'w60'}" do
        (content_tag :h2 do
          "#{pluralize(object.errors.count, 'error')} prohibited this #{object_name.humanize} from being saved:"
        end) \
        + \
        (content_tag :ul do
          raw object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
        end)
      end
    end
  end

  def instedd_table_for(data, headers, &block)
    val = content_tag :table, :class => "GralTable" do
      content_tag :tbody do
        head = content_tag :tr do
          raw(headers.map { |x| content_tag :th, x }.join)
        end

        concat(head)

        data.each do |row|
          tr = content_tag :tr do
            capture(row, &block)
          end

          concat(tr)
        end
      end
    end
  end

  def colored_button(text, color, options)
    options.merge!(:class => color)
    button_tag options do
      content_tag :span, text
    end
  end

  def orange_button(text, options={})
    colored_button text, 'orange', options
  end

  def grey_button(text, options={})
    colored_button text, 'grey', options
  end

  def white_button(text, options={})
    colored_button text, 'white', options
  end

  def orange_link_to(text, url, options={})
    options.merge!(:class => "orange button")
    link_to text, url, options
  end

  def grey_link_to(text, url, options={})
    options.merge!(:class => "grey button")
    link_to text, url, options
  end

  def white_link_to(text, url, options={})
    options.merge!(:class => "white button")
    link_to text, url, options
  end
end

module DeviseHelper  
  def devise_error_messages!(html_options = {})
    return if resource.errors.full_messages.empty?
    (content_tag :div, :class => "box error_description #{html_options[:class] || 'w60'}"  do
      (content_tag :h2, 'The following errors occurred') \
      + \
      (content_tag :ul do
        raw resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      end)
    end)
  end
end