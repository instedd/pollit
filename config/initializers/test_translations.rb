TestTranslations = false

if TestTranslations
  def _(msgid)
    "[#{I18n.locale}] #{msgid}"
  end
end