TestTranslations = false

if TestTranslations
  def _(msgid)
    "[#{I18n.locale}] #{msgid}"
  end
end

class String
  alias :interpolate_without_html_safe :%
  def %(*args)
    if args.first.is_a?(Hash)
      safe_replacement = Hash[args.first.map{|k,v| [k, v.html_safe? ? v : ERB::Util.h(v)] }]
      interpolate_without_html_safe(safe_replacement).html_safe
    else
      interpolate_without_html_safe(*args).dup
    end
  end
end

class Haml::Engine
  def tag(line)
    node = super(line)
    unless node.value[:parse] || node.value[:value].blank?
      node.value[:value] = _(node.value[:value]) 
    end
    node
  end

  def plain(text, escape_html=nil)
    text = _(text) unless text.blank? || text.include?('#{')
    super(text, escape_html)
  end
end