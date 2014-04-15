module TimeMacros

  def stub_time(time, *entities_to_reload)
    time = Time.parse(time) if time.is_a?(String)
    Time.stubs(:now).returns(time)

    Delayed::Worker.new.work_off

    entities_to_reload.each do |e|
      e.reload
    end
  end

end
