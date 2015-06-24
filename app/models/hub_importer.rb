class HubImporter

  attr_reader :poll

  def self.import_respondents_for_all
    Poll.where("hub_respondents_path IS NOT NULL").pluck(:id).each do |poll_id|
      import_respondents(poll_id)
    end
  end

  def self.import_respondents(poll_id)
    Delayed::Job.enqueue HubImporter::Job.new(poll_id)
  end

  def initialize(poll)
    @poll = poll
  end

  def import_respondents!
    return if poll.hub_respondents_path.blank? || poll.hub_respondents_phone_field.blank?

    count = 0
    hub_api.entity_set(poll.hub_respondents_path).paged_where.each_slice(100) do |respondents|
      Respondent.import [:phone, :poll_id, :hub_source], respondents.map{|r| record_from(r)}.compact, validate: false
      count += respondents.length
    end
    poll.on_respondents_added
    count
  end

  def hub_api
    @hub_api ||= HubClient::Api.trusted(poll.owner.email)
  end

  def record_from(hub_entity)
    phone = Array.wrap(poll.hub_respondents_phone_field).inject(hub_entity) {|obj, field| obj[field]} rescue nil
    phone = phone.to_s.gsub(/[^0-9]/,"") if phone
    return nil if phone.blank?
    [phone.ensure_protocol, poll.id, poll.hub_respondents_path]
  end

  class Job < Struct.new(:poll_id)

    def perform
      poll = Poll.find(poll_id)
      count = HubImporter.new(poll).import_respondents!
      Delayed::Worker.logger.info "Imported #{count} respondents for poll #{poll_id}"
    rescue ActiveRecord::RecordNotFound
      # Poll was deleted, ok to fail silently
    end

  end


end
