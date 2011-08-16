require 'open-uri'

module Poll::Parser
  extend ActiveSupport::Concern

  module ClassMethods
    def parse_form(url)
      poll = Poll.new
      doc = Nokogiri::HTML(open(url))
    
      poll.title = doc.at_xpath('//h1[@class="ss-form-title"]').text
      poll.description = doc.at_xpath('//div[contains(@class,"ss-form-desc")]').text
      poll.post_url = doc.at_xpath('//form').attribute('action').value

      doc.search('//div[contains(@class,"ss-item")]').each do |element|
        begin
          kind = question_kind(element)
          next if not kind

          question = poll.questions.build :kind => kind,
            :title => element.at_xpath('.//label[@class="ss-q-title"]').text.strip,
            :description => element.at_xpath('.//label[@class="ss-q-help"]').text.try(:strip),
            :field_name => element.at_xpath('.//input[@type="text" or @type="radio" or @type="checkbox"] | .//textarea | .//select').attribute("name").text.strip
          
          if question.kind_options?
            question.options = extract_options(element)
          elsif question.kind_numeric?
            question.numeric_min, question.numeric_max = extract_numeric(element)
          end
        rescue => ex
          raise Exception.new("Error parsing element on poll #{poll}:\n#{element.inner_html}\n#{ex.message}")
        end
      end

      return poll
    end

    private

    def extract_numeric(element)
      logger.info element.search('.//td[@class="ss-scalerow"]/input[@type="radio"]')
      element.search('.//td[@class="ss-scalerow"]/input[@type="radio"]')\
        .map{|r| r.attribute('value').value}.minmax
    end

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
        when /ss-radio/, /ss-select/ then :options
        when /ss-scale/ then :numeric
        else nil
      end
    end

  end

end