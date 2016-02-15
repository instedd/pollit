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

  has_many :questions, :order => "position", :dependent => :destroy, :inverse_of => :poll
  has_many :respondents, :dependent => :destroy
  has_many :answers, :through => :respondents

  has_one :channel, :dependent => :destroy

  has_recurrence :recurrence

  serialize :confirmation_words, Array
  serialize :hub_respondents_phone_field, Array

  validates :title, :presence => true, :length => {:maximum => 64}, :uniqueness => {:scope => :owner_id}
  validates :owner, :presence => true
  validates :form_url, :presence => true, :if => :kind_gforms?
  validates :post_url, :presence => true, :if => :kind_gforms?
  validates :welcome_message, :presence => true, :length => {:maximum => 140}
  validates :confirmation_words_text, :presence => true
  validates :goodbye_message, :presence => true, :length => {:maximum => 140}
  validates :questions, :presence => true

  validate  :collects_respondent_in_at_most_one_question

  accepts_nested_attributes_for :questions

  after_initialize :default_values

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  enum_attr :status, %w(^configuring started paused)
  enum_attr :kind,   %w(^gforms manual)

  include Parser
  include AcceptAnswers
  include RecurrenceStrategy

  def confirmation_words_text
    self.confirmation_words.join(', ')
  end

  def confirmation_words_text=(value)
    self.confirmation_words = value.split(',').map(&:strip)
  end

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
    respondents_to_invite = self.respondents.where(:current_question_sent => false, :confirmed => false)
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

  def respondent_question
    self.questions.where(collects_respondent: true).first
  end

  def duplicate
    duplicate = self.dup
    duplicate.current_occurrence = nil

    count = 2
    title = self.title

    case title
    when /\A(.+?)\s+\(Copy\)\Z/
      title = $1
      duplicate.title = "#{title} (Copy 2)"
      count = 3
    when /\A(.+?)\s+\(Copy\s+(\d+)\)\Z/
      title = $1
      n = $2.to_i
      duplicate.title = "#{title} (Copy #{n + 1})"
      count = n + 2
    else
      duplicate.title = "#{title} (Copy)"
    end

    duplicate.status = :configuring

    count = 2
    while Poll.where(owner_id: owner_id, title: duplicate.title).exists?
      duplicate.title = "#{title} (Copy #{count})"
      count += 1
    end

    self.questions.each do |question|
      duplicate_question = question.dup
      duplicate_question.poll = duplicate
      duplicate.questions << duplicate_question
    end

    self.respondents.each do |respondent|
      duplicate_respondent = respondent.dup
      duplicate_respondent.poll = duplicate
      duplicate_respondent.confirmed = false
      duplicate_respondent.pushed_at = nil
      duplicate_respondent.pushed_status = "pending"
      duplicate_respondent.current_question_id = nil
      duplicate_respondent.current_question_sent = false
      duplicate.respondents << duplicate_respondent
    end

    duplicate.save!
    duplicate
  end

  private

  def invite(respondents)
    respondents.find_in_batches(batch_size: 100) do |batch|
      messages = batch.map {|r| message_to(r, welcome_message)}
      send_messages messages
      Respondent.where(id: batch.map(&:id)).update_all :current_question_sent => true
    end
  end

  def default_values
    self.confirmation_words   = [_("Yes")] if self.confirmation_words.blank?
    self.welcome_message   ||= _('Reply YES to agree to participate in this poll')
    self.goodbye_message   ||= _("Thank you for your answers!")
  rescue
    true
  end

  def collects_respondent_in_at_most_one_question
    if self.questions.select{ |q| !q.marked_for_destruction? && q.collects_respondent }.length > 1
      errors.add(:questions, " cannot collect respondent in more than one question")
    end
  end

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.owner)
  end
end
