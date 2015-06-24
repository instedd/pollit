require 'spec_helper'

describe HubImporter do

  let(:path)  { 'connectors/CONNECTORGUID/indices/contacts/types/contact' }
  let(:host)  { 'http://hub-test.instedd.org/'}

  let(:api) { double('api') }

  before(:each) do
    HubClient::Config.any_instance.stub(:url).and_return(host)
    HubClient::Api.stub(:trusted).and_return(api)
    api.stub(:entity_set).and_return { |path| HubClient::EntitySet.new(api, path) }
  end

  def json(path)
    JSON.parse(File.read("#{Rails.root}/spec/webmocks/#{path}"))
  end

  def it_should_have_two_respondents(poll)
    poll.reload.should have(2).respondents
    poll.respondents.pluck(:phone).should eq(["sms://9991001", "sms://9991002"])
    poll.respondents.pluck(:hub_source).should eq([path, path])
  end

  it "should enqueue jobs for all polls with hub configured" do
    with_hub = Poll.make!(3, hub_respondents_path: 'example.com')
    Poll.make!(2)

    expect {
      HubImporter.import_respondents_for_all
    }.to change(Delayed::Job, :count).by(3)
  end

  it "should fail silently if hub path was removed" do
    poll = Poll.make!(hub_respondents_path: nil)
    HubImporter.new(poll).import_respondents!.should be_nil
  end

  it "should import respondents from hub" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.stub(:json).and_return({
      "items" => [
        { "phone" => "9991001", "name" => "Joe"},
        { "phone" => "sms://9991002", "name" => "Jane"}
      ]
    })

    HubImporter.new(poll).import_respondents!
    it_should_have_two_respondents(poll)
  end

  it "should import respondents from hub with complex field" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phones','main'])
    api.stub(:json).and_return({
      "items" => [
        { "phones" => { 'main' => "9991001" }, "name" => "Joe"},
        { "phones" => { 'main' => "9991002" }, "name" => "Joe"},
      ]
    })

    HubImporter.new(poll).import_respondents!
    it_should_have_two_respondents(poll)
  end

  it "should skip respondents without phone" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.stub(:json).and_return({
      "items" => [
        { "phone" => "9991001", "name" => "Joe"},
        { "phone" => "sms://9991002", "name" => "Jane"},
        { "mobile" => "9991003", "name" => "Jack"}
      ]
    })

    HubImporter.new(poll).import_respondents!
    it_should_have_two_respondents(poll)
  end

  it "should skip respondents without valid phone" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.stub(:json).and_return({
      "items" => [
        { "phone" => "9991001", "name" => "Joe"},
        { "phone" => "sms://9991002", "name" => "Jane"},
        { "phone" => "foobar", "name" => "Jack"}
      ]
    })

    HubImporter.new(poll).import_respondents!
    it_should_have_two_respondents(poll)
  end

  it "should remove invalid characters when importing" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.stub(:json).and_return({
      "items" => [
        { "phone" => "+(99)91-001", "name" => "Joe"},
        { "phone" => "sms://9991002", "name" => "Jane"}
      ]
    })

    HubImporter.new(poll).import_respondents!
    it_should_have_two_respondents(poll)
  end

  it "should import repeated respondents" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.stub(:json).and_return({
      "items" => [
        { "phone" => "9991001", "name" => "Joe"},
        { "phone" => "9991001", "name" => "Jane"},
        { "phone" => "9991002", "name" => "Jack"}
      ]
    })

    HubImporter.new(poll).import_respondents!
    it_should_have_two_respondents(poll)
  end

  it "should import with existing respondents" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'], respondents: [Respondent.make(phone: "sms://9991001")])
    api.stub(:json).and_return({
      "items" => [
        { "phone" => "9991001", "name" => "Joe"},
        { "phone" => "9991001", "name" => "Jane"},
        { "phone" => "9991002", "name" => "Jack"}
      ]
    })

    HubImporter.new(poll).import_respondents!
    poll.should have(2).respondents
    poll.respondents.pluck(:phone).should eq(["sms://9991001", "sms://9991002"])

    poll.respondents.first.hub_source.should be_nil
    poll.respondents.last.hub_source.should_not be_nil
  end

  it "should import respondents from several pages in hub" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.should_receive(:json).with("/api/data/#{path}?") { json('hub-respondents-large-p1.json') }
    api.should_receive(:json).with("/api/data/#{path}?page=2") { json('hub-respondents-large-p2a.json') }

    expect {
      HubImporter.new(poll).import_respondents!
    }.to change(Respondent, :count).by(231)

    poll.respondents.pluck(:phone).should =~ ((99910000..99910230).to_a.map{|p| "sms://#{p}"})
  end

  it "should import respondents from several pages in hub with repeated numbers" do
    poll = Poll.make!(hub_respondents_path: path, hub_respondents_phone_field: ['phone'])
    api.should_receive(:json).with("/api/data/#{path}?") { json('hub-respondents-large-p1.json') }
    api.should_receive(:json).with("/api/data/#{path}?page=2") { json('hub-respondents-large-p2b.json') }

    expect {
      HubImporter.new(poll).import_respondents!
    }.to change(Respondent, :count).by(200)

    poll.respondents.pluck(:phone).should =~ ((99910000..99910199).to_a.map{|p| "sms://#{p}"})
  end

end
