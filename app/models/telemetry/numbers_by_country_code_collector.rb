module Telemetry::NumbersByCountryCodeCollector
  def self.collect_stats(period)
    {counters: polls_counters(period).concat(global_counters(period))}
  end

  def self.polls_counters(period)
    respondents = Respondent.where('created_at < ?', period.end).select('distinct phone, poll_id')
    poll_data = {}

    respondents.each do |respondent|
      poll_id = respondent.poll_id
      number = respondent.phone.without_protocol
      country_code = InsteddTelemetry::Util.country_code number
      if country_code.present?
        poll_data[poll_id] ||= Hash.new(0)
        poll_data[poll_id][country_code] += 1
      end
    end

    counters = poll_data.inject [] do |r, (application_id, numbers_by_country_code)|
      r.concat(numbers_by_country_code.map do |country_code, count|
        {
          metric: 'unique_phone_numbers_by_project_and_country',
          key: {project_id: application_id, country_code: country_code},
          value: count
        }
      end)
    end

    counters
  end

  def self.global_counters(period)
    numbers = Respondent.where('created_at < ?', period.end).pluck('distinct phone')

    numbers_by_country_code = Hash.new(0)

    numbers.each do |number|
      number = number.without_protocol
      country_code = InsteddTelemetry::Util.country_code number
      numbers_by_country_code[country_code] += 1 if country_code.present?
    end

    counters = numbers_by_country_code.map do |country_code, count|
      {
        metric: 'unique_phone_numbers_by_country',
        key: {country_code: country_code},
        value: count
      }
    end

    counters
  end
end
