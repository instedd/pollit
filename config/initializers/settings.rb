ConfigFilePath = "#{::Rails.root.to_s}/config/settings.yml"
raise Exception, "#{ConfigFilePath} configuration file is missing" unless FileTest.exists?(ConfigFilePath)

YAML.load_file(ConfigFilePath)[::Rails.env].each do |k,v|
  Pollit::Application.config.send("#{k}=", v)
end

