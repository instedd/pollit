TestTranslations = false

if TestTranslations
  def _(msgid)
    "[#{I18n.locale}] #{msgid}"
  end
end

Haml::Template.enable_magic_translations(:fast_gettext)
I18n.load_path += Dir["config/locales/*.{po}")]

