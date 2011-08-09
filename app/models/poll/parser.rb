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
        kind = question_kind(element)
        next if not kind
        poll.questions.build :kind => kind,
          :title => element.at_xpath('.//label[@class="ss-q-title"]').text.strip,
          :description => element.at_xpath('.//label[@class="ss-q-help"]').text.try(:strip),
          :options => extract_options(element)
      end

      return poll
    end

    private

    def extract_options(element)
      case element.attribute('class').value
        when /ss-select/ then element.search('.//option')
        when /ss-checkbox/ then element.search('.//input[contains(@class,"ss-q-checkbox")]')
        when /ss-radio/ then element.search('.//input[contains(@class,"ss-q-radio")]')
        else []
      end.map{|opt| opt.attribute('value').value}.reject{|opt| opt == '__option__'}
    end

    def question_kind(element)
      case element.attribute('class').value
        when /ss-text/, /ss-paragraph-text/ then :text
        when /ss-radio/, /ss-checkbox/, /ss-select/ then :options
        else nil
      end
    end

  end

end