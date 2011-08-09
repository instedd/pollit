require 'open-uri'

module Poll::Parser
  extend ActiveSupport::Concern

  module ClassMethods
    def parse_form(url)
      poll = Poll.new
      doc = Nokogiri::HTML(open(url))
    
      poll.title = doc.at_xpath('//h1[@class="ss-form-title"]').text
      poll.description = doc.at_xpath('//div[contains(@class,"ss-form-desc")]').text

      doc.search('//div[contains(@class,"ss-item")]').each do |element|
        p element
        kind = question_kind(element)
        p kind
        next if not kind
        poll.questions.build :kind => kind,
          :title => element.at_xpath('.//label[@class="ss-q-title"]').text.strip,
          :description => element.at_xpath('.//label[@class="ss-q-help"]').text.try(:strip)
      end

      return poll
    end

    private

    def question_kind(element)
      case element.attribute('class').value
        when /ss-text/, /ss-paragraph-text/ then :text
        when /ss-radio/, /ss-checkbox/, /ss-select/ then :options
        else nil
      end
    end

  end

end