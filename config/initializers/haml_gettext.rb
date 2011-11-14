class Haml::Engine
  
  def parse_tag(line)
    tag_name, attributes, attributes_hash, object_ref,
    nuke_outer_whitespace, nuke_inner_whitespace,
    action, value = super(line)
    
    puts "Value before translate #{value}"
    value = _(value)
    puts "Value after translate #{value}"
    
    [tag_name, attributes, attributes_hash, object_ref, nuke_outer_whitespace, nuke_inner_whitespace, action, value]
  end

  def plain(text, escape_html=nil)
    puts "Value before translate #{text}"
    text = _(text) unless text.include?('#{')
    puts "Value after translate #{text}"
    super(text, escape_html)
  end

end