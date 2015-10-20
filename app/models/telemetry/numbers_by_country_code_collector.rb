module Telemetry::NumbersByCountryCodeCollector
  def self.collect_stats(period)
    numbers = Respondent.where('created_at < ?', period.end).pluck('distinct phone')

    numbers_by_country_code = Hash.new(0)

    numbers.each do |number|
      number = number.without_protocol
      country_code = InsteddTelemetry::Util.country_code number
      numbers_by_country_code[country_code] += 1 if country_code.present?
    end

    counters = numbers_by_country_code.map do |country_code, count|
      {
        metric: 'numbers_by_country_code',
        key: {country_code: country_code},
        value: count
      }
    end

    {counters: counters}
  end
end
