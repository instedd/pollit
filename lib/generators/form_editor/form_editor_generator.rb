class FormEditorGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :parent_class, :type => :string, :desc => "Class that will contain the form fields"
  argument :item_name, :type => :string, :default => 'field', :desc => "Name of each item in the form"
  argument :form_editor_name, :type => :string, :default => 'form_editor', :desc => "Name of the form editor"
  
  class_option :images_folder, :type => :string, :default => 'form_editor', :desc => "Target folder for images within app/assets/images"
  class_option :images, :type => :boolean, :default => true, :desc => "Whether to copy images to assets folder"
  class_option :views_folder, :type => :string, :desc => "Target folder for views, by default a subfolder 'form_editor' in the parent class views folder"

  def generate_form_editor
    copy_file 'form_editor.js', "app/assets/javascripts/form_editor.js"
    template 'form_editor.sass.erb', "app/assets/stylesheets/form_editor.sass"
    
    directory 'images', File.join("app/assets/images", images_path) if options.images?

    empty_directory app_views_path

    template '_fields.haml.erb',       app_views_path("_#{fields_view_name}.haml")
    template '_field.haml.erb',        app_views_path("_#{field_view_name}.haml")
    template '_field_add.haml.erb',    app_views_path("_#{field_add_view_name}.haml")
    template '_field_form.haml.erb',   app_views_path("_#{field_form_view_name}.haml")
    template '_field_option.haml.erb', app_views_path("_#{field_option_view_name}.haml")
  end

  private

  # Paths

  def images_path(filename=nil)
    path = "#{options.images_folder.underscore}"
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

  # Item methods

  def item_type_has_options
    "#{item_type}_has_options?"
  end

  def item_type
    "#{item_name}_type"
  end

  def item_type_label
    "#{item_type}_label"
  end

  def item_types
    "#{item_type}s"
  end

end
