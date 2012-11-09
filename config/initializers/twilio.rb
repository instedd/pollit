twilio = YAML.load_file("#{Rails.root}/config/twilio.yml")
::Pollit::TwilioAccountSid = twilio['account_sid']
::Pollit::TwilioAuthToken = twilio['auth_token']
::Pollit::TwilioConnectKey = twilio['connect_key']
