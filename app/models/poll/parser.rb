# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

module Poll::Parser
  extend ActiveSupport::Concern

  def parse_form
    doc = Nokogiri::HTML(Mechanize.new.get(self.form_url).body)

    self.title = doc.at_xpath('//h1[@class="ss-form-title"]').text if self.title.blank?
    self.description = doc.at_xpath('//div[contains(@class,"ss-form-desc")]').try(:text) if self.description.blank?
    self.post_url = doc.at_xpath('//form').attribute('action').value

    position = 0
    doc.search('//div[contains(@class,"ss-item")]').each do |element|
      begin
        kind = question_kind(element)
        next if not kind
        position += 1
        question = self.questions.build :kind => kind,
          :title => element.at_xpath('.//*[@class="ss-q-title"]').try(:text).try(:strip),
          :description => element.at_xpath('.//*[@class="ss-q-help"]').try(:text).try(:strip),
          :field_name => element.at_xpath('.//input[@type="text" or @type="radio" or @type="checkbox"] | .//textarea | .//select').attribute("name").text.strip,
          :position => position

        if question.kind_options?
          question.options = extract_options(element)
        elsif question.kind_numeric?
          question.numeric_min, question.numeric_max = extract_numeric(element)
        elsif question.kind_text?
          question.must_contain = extract_text(element)
        end
      rescue => ex
        raise Exception.new("Error parsing element on poll #{self}:\n#{element.inner_html}\n#{ex.message}")
      end
    end
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

  def extract_text(element)
    input = element.at_xpath('.//input[@type="text"]')
    return $1 if input && input.attribute('pattern').try(:value) =~ /\A\.\*(.+)\.\*\Z/
  end

  def question_kind(element)
    case element.attribute('class').value
      when /ss-text/, /ss-paragraph-text/ then :text
      when /ss-radio/, /ss-select/ then :options
      when /ss-scale/ then :numeric
      when /ss-navigate/ then nil
      else :unsupported
    end
  end

  module ClassMethods
    def parse_form(url)
      poll = Poll.new
      poll.form_url = url
      poll.parse_form
      return poll
    end
  end
end
