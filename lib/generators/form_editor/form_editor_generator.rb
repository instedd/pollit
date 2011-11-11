class FormEditorGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :parent_class, :type => :string, :desc => "Class that will contain the form fields"
  argument :item_name, :type => :string, :default => 'field', :desc => "Name of each item in the form"
  argument :form_editor_name, :type => :string, :default => 'form_editor', :desc => "Name of the form editor"
  
  class_option :images_folder, :type => :string, :default => 'form_editor', :desc => "Target folder for images within app/assets/images"
  class_option :images, :type => :boolean, :default => true, :desc => "Whether to copy images to assets folder"
  class_option :views_folder, :type => :string, :desc => "Target folder for views, by default a subfolder 'form_editor' in the parent class views folder"

  class_option :item_type_enum, :type => :string, :desc => "Enum name for the type of a form item, such as numeric, text or option; defaults to [item_name]_type"
  class_option :item_type_has_options_method, :type => :string, :desc => "Method for querying whether an item supports options, defaults to [item_name]_type_has_options?"

  class_option :item_name_attr, :type => :string, :default => 'name', :desc => "Attribute name for the field's name"
  class_option :item_hint_attr, :type => :string, :default => 'hint', :desc => "Attribute name for the field's hint"
  class_option :item_opts_attr, :type => :string, :default => 'options', :desc => "Attribute name for the field's options array"

  class_option :item_has_required, :type => :boolean, :default => true, :desc => "Whether there is a required flag for the item"

  def generate_form_editor
    copy_file 'form_editor.js', "app/assets/javascripts/form_editor.js"
    directory 'images', File.join("app/assets/images", images_path) if options.images?

    template 'form_editor.sass.erb', "app/assets/stylesheets/form_editor.sass"
    template 'form_editor_helper.rb.erb', "app/helpers/#{form_editor_name.underscore}_helper.rb"

    empty_directory app_views_path

    template 'views/_fields.haml.erb',       app_views_path("_#{fields_view_name}.haml")
    template 'views/_field.haml.erb',        app_views_path("_#{field_view_name}.haml")
    template 'views/_field_add.haml.erb',    app_views_path("_#{field_add_view_name}.haml")
    template 'views/_field_form.haml.erb',   app_views_path("_#{field_form_view_name}.haml")
    template 'views/_field_option.haml.erb', app_views_path("_#{field_option_view_name}.haml")

    puts <<FINISH

To use the #{form_editor_name.humanize.downcase}, create a form for your #{parent_class} class with the following code:

  = form_for @#{parent_class.underscore} do |form_builder|
    = render :partial => '#{views_path(fields_view_name)}', :locals => { :f => form_builder }

Class #{parent_class.classify} must define a method for obtaining all #{item_name.pluralize.humanize.downcase}:

    #{items}

Class #{item_class.classify} must define the following attributes:

  #{item_name_attribute}
  #{item_hint_attribute}
  #{item_opts_attribute}
  #{item_type_has_options}
  #{'required' if handle_required?}

And the following enum_attr:

  #{item_type}

FINISH

  end

  private

  # Misc

  def handle_required?
    options.item_has_required?
  end

  # Paths

  def images_path(filename=nil)
    path = "#{options.images_folder.underscore}/"
    return path if not filename
    File.join(path, filename)
  end

  def views_path(filename=nil)
    path = options.views_folder || "#{parent_class.pluralize.underscore}/#{form_editor_name.underscore}"
    return path if not filename
    File.join(path, filename)
  end

  def app_views_path(filename=nil)
    File.join('app/views', views_path(filename))
  end

  # View Names

  def fields_view_name
    item_name.pluralize.underscore
  end

  def field_view_name
    item_name.underscore
  end

  def field_form_view_name
    "#{item_name.underscore}_form"
  end

  def field_add_view_name
    "#{item_name.underscore}_add"
  end

  def field_option_view_name
    "#{item_name.underscore}_option"
  end

  # Item names

  def items
    item_name.pluralize.underscore
  end

  def item
    item_name.underscore
  end

  def item_class
    item_name.camelize
  end

  def item_pretty
    item_name.humanize.downcase
  end

  def items_pretty
    item_name.pluralize.humanize.downcase
  end

  # Item types

  def item_type
    options[:item_type_enum] || "#{item_name}_type"
  end

  def item_type_has_options
    options[:item_type_has_options_method] || "#{item_type}_has_options?"
  end

  def item_type_label
    "#{item_types}.label"
  end

  def item_types
    "#{item_class}.new.#{item_type}s"
  end

  # Item attributes

  def item_name_attribute
    options[:item_name_attr]
  end

  def item_hint_attribute
    options[:item_hint_attr]
  end

  def item_opts_attribute
    options[:item_opts_attr]
  end

end
