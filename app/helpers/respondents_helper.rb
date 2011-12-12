module RespondentsHelper
  
  def can_edit
    @poll.status_configuring?
  end
  
  def phones_list
    can_edit ? phones : []
  end
  
  def fixed_phones_list
    can_edit ? [] : phones
  end
  
  private
  
  def phones
    @poll.respondents.map{|x| {:number => x.unprefixed_phone}}
  end
  
end
