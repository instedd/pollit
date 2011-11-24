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
    if block_opened?
      raise SyntaxError.new("Illegal nesting: nesting within plain text is illegal.", @next_line.index)
    end

    unless contains_interpolation?(text)
      return ParseNode.new(:plain, @index, :text => _(text))
    end

    escape_html = @options[:escape_html] if escape_html.nil?
    value = handle_i18n_interpolation(text, escape_html)
    script(value, !:escape_html)
  end

  def handle_i18n_interpolation(str, escape_html)
    args = []
      res  = ''
      str = str.
        gsub(/\n/, '\n').
        gsub(/\r/, '\r').
        gsub(/\#/, '\#').
        gsub(/\"/, '\"').
        gsub(/\\/, '\\\\')
        
      count = 1
      rest = Haml::Shared.handle_interpolation '"' + str + '"' do |scan|
        escapes = (scan[2].size - 1) / 2
        res << scan.matched[0...-3 - escapes]
        if escapes % 2 == 1
          res << '#{'
        else
          content = eval('"' + balance(scan, ?{, ?}, 1)[0][0...-1] + '"')
          content = "Haml::Helpers.html_escape(#{content.to_s})" if escape_html
          args << content
          res  << "%s"
          count += 1
        end
      end
      value = res+rest.gsub(/\\(.)/, '\1').chomp
      value = value[1..-2] unless value.to_s == ''
      args  = "[#{args.join(', ')}]"
      value = "_('#{value.gsub(/'/, "\\\\'")}') % #{args}\n"
  end

end