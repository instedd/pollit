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

  def instedd_table_for(data, headers, empty=nil, &block)
    val = content_tag :table, :class => "GralTable" do
      content_tag :tbody do
        concat (content_tag :tr do
          raw(headers.map { |x| content_tag :th, x }.join)
        end)

        if data.empty?
          empty_opts = {:class => "EmptyData", :text => "There are no records to display"}
          empty = empty.kind_of?(Hash) ? empty : {text: empty || empty_opts[:text]}
          empty_opts.merge! empty

          concat (content_tag :tr do
            content_tag :td, empty_opts[:text], :colspan => 0, :class => empty_opts[:class]
          end)
        else
          data.each do |row|
            concat (content_tag :tr do
              capture(row, &block)
            end)
          end
        end
      end
    end
  end

  def colored_button(color, text, options={})
    options.merge!(:class => "#{color} #{options[:class]}")
    button_tag options do
      content_tag :span, text
    end
  end

  def colored_link_to(color, text, url, options={})
    options.merge!(:class => "button #{color} #{options[:class]}")
    link_to text, url, options
  end

  def fancy_button(content, kind, options={})
    options.merge!(:class => "#{kind} #{options[:class]}", :type => 'button')
    button_tag content, options
  end

  ['orange', 'grey', 'white'].each do |color|
    define_method "#{color}_button" do |*args| 
      colored_button *([color] + args)
    end

    define_method "#{color}_link_to" do |*args| 
      colored_link_to *([color] + args)
    end
  end

  def order_class(index, total)
    if index == 0
      "first"
    elsif index == total-1
      "last"
    else
      ""
    end
  end

  class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
    def render
      return "" if @elements.empty?
      "<div class='BreadCrumb'><ul>#{@elements.map{|e| "<li>#{item e}</li>"}.join}</ul></div>"
    end  
    def item(element)
      @context.link_to_unless_current(compute_name(element), compute_path(element))
    end
  end

  def breadcrumb
    raw render_breadcrumbs :builder => BreadcrumbBuilder
  end

  def progress_bar(completed_amount, total_amount)
    return if total_amount == 0
    percentage = ((completed_amount.to_f/total_amount.to_f)*100).round(0).to_s

    content_tag :div, :class => "smvalues" do
      concat(content_tag(:div, :class => "L") do
        content_tag(:span)  { completed_amount.to_s }
      end)
      concat(content_tag(:div, :class => "R") do
        content_tag(:span)  { total_amount.to_s }
      end)
      concat(tag(:br, :clear => :all))
      concat(content_tag(:div, :class => "M") do
        tag(:span, :style => "width:#{percentage}%")
      end)
    end
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