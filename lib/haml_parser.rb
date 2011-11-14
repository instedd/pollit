#This module used for crating the .pot file and
# this file conatins all views in pain text.

require 'rubygems'
require 'haml'
require 'gettext/tools'

class Haml::Engine
  
  attr_accessor :gettext_code

  def parse_tag(line)
    tag_name, attributes, attributes_hash, object_ref,
    nuke_outer_whitespace, nuke_inner_whitespace,
    action, value = super(line)

    push_gettext(value)
    
    [tag_name, attributes, attributes_hash, object_ref, nuke_outer_whitespace, nuke_inner_whitespace, action, value]
  end

  def plain(text, escape_html=nil)
    #push_gettext(text)
    super(text, escape_html)
  end

  def push_text(text, tab_change=0)
    push_gettext(text)
  end

  def push_silent(text, can_suppress = false)
    push_gettext_script(text)
  end

  def push_generated_script(text)
    push_gettext_script(text)
  end

  def push_script(text, opts = {})
    push_gettext_script(text)
  end

  def push_gettext(text)
    gettext_code  << "_(\"#{text}\")" unless text.blank? || text.include?('#{')
  end

  def push_gettext_script(text)
    gettext_code << text
  end

  def gettext_code
    (@gettext_code ||= [])
  end
end

# Haml gettext parser
module HamlParser
  module_function

  def target?(file)
    File.extname(file) == '.haml'
  end

  def parse(file, ary = [])
    puts "HamlParser:#{file}"
    haml = Haml::Engine.new(IO.readlines(file).join)
    result = nil
    begin
      code = haml.gettext_code
      puts "Tha code:"
      code.each do |line|
        puts line
      end
      result = GetText::RubyParser.parse_lines(file, code, ary)
      # result = RubyGettextExtractor.parse_string(haml.precompiled, file, ary)
    rescue Exception => e
      puts "Error:#{file}"
      raise e
    end
    result
  end
end

GetText::RGetText.add_parser(HamlParser)