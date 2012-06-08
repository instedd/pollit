# Copyright (C) 2011-2012, InSTEDD
# 
# This file is part of Pollit.
# 
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

module FormEditorHelper
  
  def form_editor_class_for(kind)
    case kind
      when :text then 'ltext'
      when :options then 'lsingleoption'
      when :numeric then 'lnumber'
      when :unsupported then 'lunknown' 
      else ''
    end
  end

  def link_to_add_question_option(f, opts={})
    content = render :partial => 'polls/form_editor/question_option', :object => "new_option", :locals => {:f => f}
    opts = {:onclick => %Q<
      add_field_option(this, "new_option", "#{escape_javascript(content)}");
      return false;>}.merge(opts)
    
    if block_given? then
      link_to "#", opts {yield}
    else
      link_to "", "#", opts
    end
  end
  
  def link_to_add_question(f, kind, opts={})
    new_object = Question.new(:title => "New question", :kind => kind)
    index = "new_field_index"
    
    field_container = '#form-editor .fields-list'
    field_content = render('polls/form_editor/question', :question => new_object, :question_counter => index)
    
    form_container = '#form-editor .fieldsidebar'
    form_content = f.fields_for(:questions, new_object, :child_index => index) do |builder|
      render :partial => 'polls/form_editor/question_form', :object => builder, :locals => {:index => index}
    end
    
    link_to "#", {:onclick => %Q<
      var new_index = Math.floor(Math.random() * 1073741824);
      add_field("#{index}", new_index, "#{field_container}", "#{escape_javascript(field_content)}");
      add_field("#{index}", new_index, "#{form_container}", "#{escape_javascript(form_content)}");
      select_field(new_index);
      return false;>}.merge(opts) do
      yield if block_given?
    end
  end
end