FastGettext.add_text_domain 'app', :path => 'locale', :type => :po
FastGettext.default_available_locales = ['en','es']
FastGettext.default_text_domain = 'app'
FastGettext.default_locale = 'es'

needed = "".respond_to?(:html_safe) and
  (
    "".html_safe % {:x => '<br/>'} == '<br/>' or
    not ("".html_safe % {:x=>'a'}).html_safe?
  )

puts "Needed #{needed}"

GettextI18nRails.translations_are_html_safe = true
require 'gettext_i18n_rails/string_interpolate_fix'