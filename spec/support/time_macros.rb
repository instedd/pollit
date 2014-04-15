module TimeMacros

  def stub_time(time)
    time = Time.parse(time) if time.is_a?(String)
    Time.stubs(:now).returns(time)

    Delayed::Worker.new.work_off
  end

end
