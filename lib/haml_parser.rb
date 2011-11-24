require 'rubygems'
require 'haml'
require 'gettext/tools'

class Haml::Engine
  
  attr_accessor :gettext_code

  def tag(line)
    node = super(line)
    if !node.value[:parse]
      push_gettext(node.value[:value])
    else
      push_gettext_script(node.value[:value])
    end
    node
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

  def gettext_code
    (@gettext_code ||= [])
  end

  private

  def push_gettext(text)
    gettext_code  << "_(\"#{text.gsub(/"/,'\"')}\")\n" unless text.blank? || text.include?('#{') || text.include?('<!--')
  end

  def push_gettext_script(text)
    unless text.blank?
      gettext_code << text 
      gettext_code << "\n" unless text.end_with?("\n")
    end
  end
  
end

# Haml gettext parser
module HamlParser
  module_function

  def target?(file)
    File.extname(file) == '.haml'
  end

  def parse(file, ary = [])
    puts "HamlParser: #{file}"
    haml = Haml::Engine.new(IO.readlines(file).join)
    result = nil
    begin
      code = haml.gettext_code
      code.each { |line| puts " #{line}" }
      result = GetText::RubyParser.parse_lines(file, code, ary)
    rescue Exception => e
      puts "Error:#{file}"
      raise e
    end
    result
  end
end

GetText::RGetText.add_parser(HamlParser)