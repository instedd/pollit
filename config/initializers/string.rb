class String

  def with_protocol(protocol='sms')
    "#{protocol}://#{self}"
  end

  def without_protocol
    last_slash = self.rindex('/')
    if last_slash.nil?
      self
    else
      self.from(self.rindex('/')+1)
    end
  end

  def has_protocol?
    self =~ /^\w+:\/\//
  end

  def ensure_protocol
    has_protocol? ? self : self.with_protocol
  end

end
