class String
  def to_phone_number
    gsub /[^0-9]/, ''
  end

  def to_twitter
    gsub /\A@/, ''
  end
end