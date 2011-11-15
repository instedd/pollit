TestTranslations = true

FastGettext.add_text_domain 'app', :path => 'config/locales', :type => :po
FastGettext.default_available_locales = ['en','es']
FastGettext.default_text_domain = 'app'
FastGettext.default_locale = 'es'

GettextI18nRails.translations_are_html_safe = true

class String
  alias :interpolate_without_html_safe :%
  def %(*args)
    if html_safe?
      interpolate_without_html_safe(*args).html_safe
    else
      interpolate_without_html_safe(*args)
    end
  end
end

if TestTranslations && Rails.env.development?
  def _(msgid)
    "[#{I18n.locale}] #{msgid}"
  end
end