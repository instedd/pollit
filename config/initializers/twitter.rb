::Pollit::TwitterConsumerConfig = YAML.load_file "#{Rails.root}/config/twitter.yml"
Twitter.configure do |config|
  config.consumer_secret = ::Pollit::TwitterConsumerConfig['consumer_secret']
  config.consumer_key = ::Pollit::TwitterConsumerConfig['consumer_key']
end