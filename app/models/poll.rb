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

class Poll < ActiveRecord::Base
  MESSAGE_FROM = "sms://0"

  belongs_to :owner, :class_name => User.name
  has_many :questions, :order => "position", :dependent => :destroy
  has_many :respondents, :dependent => :destroy
  has_many :answers, :through => :respondents, :order => 'created_at'
  has_one :channel, :dependent => :destroy

  has_recurrence :recurrence

  validates :title, :presence => true, :length => {:maximum => 64}, :uniqueness => {:scope => :owner_id}
  validates :owner, :presence => true
  validates :form_url, :presence => true
  validates :welcome_message, :presence => true, :length => {:maximum => 140}
  validates :post_url, :presence => true
  validates :confirmation_word, :presence => true
  validates :goodbye_message, :presence => true, :length => {:maximum => 140}
  validates :questions, :presence => true

  accepts_nested_attributes_for :questions

  after_initialize :default_values

  enum_attr :status, %w(^configuring started paused)

  include Parser
  include AcceptAnswers
  include RecurrenceStrategy

  def generate_unique_title!
    return unless self.title && self.owner_id
    escaped_title = self.title.gsub('%', '\%').gsub('_', '\_')
    matches = self.class.where("owner_id = ? AND title LIKE ?", owner_id, "#{escaped_title}%").select('title')
    unless matches.empty?
      index =  2
      index += 1 while matches.any?{|p| p.title.downcase == "#{title} #{index}".downcase}
      self.title = "#{title} #{index}"
    end
  end

  def start
    raise Exception.new("Cannot start poll #{self.id}") unless can_be_started?
    self.recurrence_strategy.start

    self.status = :started
    save
  end

  def editable?
    status_configuring?
  end

  def can_be_started?
    status_configuring? && channel && respondents.any?
  end

  def pause
    raise Exception.new("Cannot pause unstarted poll #{self.id}") unless self.status_started?
    self.recurrence_strategy.pause
    self.status = :paused
    self.save
  end

  def resume
    raise Exception.new("Cannot resume unpaused poll #{self.id}") unless self.status_paused?
    self.recurrence_strategy.resume

    self.status = :started
    self.save
  end

  def as_channel_name
    "#{title}-#{id}".parameterize
  end

  def register_channel(ticket_code)
    Channel.create({
      :ticket_code => ticket_code,
      :name => as_channel_name,
      :poll_id => id
    })
  end

  def completion_percentage
    if answers_expected == 0
      "0%"
    else
      ((questions_answered.to_f / answers_expected.to_f)*100).round(0).to_i.to_s + "%"
    end
  end

  def google_form_key
    return nil unless form_url || post_url
    query = URI.parse(form_url || post_url).query
    CGI::parse(query)['formkey'][0]
  end

  def on_respondents_added
    invite_new_respondents if status_started?
  end

  def invite_all_respondents
    invite respondents
  end

  def invite_new_respondents
    respondents_to_invite = self.respondents.where(:current_question_sent => false).where(:confirmed => false)
    invite respondents_to_invite
  end

  # public only cause recurrence_strategy need to use it

  def send_messages(messages)
    begin
      Nuntium.new_from_config.send_ao messages
    rescue MultiJson::DecodeError
      # HACK until nuntium ruby api is fixed
    end
  end

  def message_to(respondent, body)
    return {
      :from => MESSAGE_FROM,
      :to => respondent.phone,
      :body => body,
      :poll_id => self.id.to_s
    }
  end

  private

  def invite(respondents)
    messages = []

    respondents.each do |respondent|
      messages << message_to(respondent, welcome_message)
    end

    # mark respondents as invited
    respondents.update_all :current_question_sent => true

    send_messages messages
  end

  def default_values
    self.confirmation_word ||= _("Yes")
    self.welcome_message ||= _("Answer 'yes' if you want to participate in this poll.")
    self.goodbye_message ||= _("Thank you for your answers!")
  rescue
    true
  end
end
