class Haml::Engine
  
  def tag(line)
    node = super(line)
    unless node.value[:parse] || node.value[:value].blank?
      puts "Translating value from #{node.value[:value]} to #{_(node.value[:value])}"
      node.value[:value] = _(node.value[:value]) 
    end
    node
  end

  def plain(text, escape_html=nil)
    text = _(text) unless text.blank? || text.include?('#{')
    super(text, escape_html)
  end

end