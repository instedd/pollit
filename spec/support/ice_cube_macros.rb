module IceCubeMacros

  def weekly_json(*days)
    IceCube::Rule.weekly.day(*days).to_hash.to_json
  end

  def days_of_weekly_rule(schedule)
    schedule.recurrence_rules.first.to_hash[:validations][:day]
  end
end
