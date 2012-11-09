class String
  def to_phone_number
    gsub /[^0-9]/, ''
  end
end