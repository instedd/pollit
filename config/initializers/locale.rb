module Locales

  def available
    Pollit::Application.config.available_locales
  end

  def default
    Pollit::Application.config.default_locale
  end

  def many?
    available.count > 1
  end

  extend self

end