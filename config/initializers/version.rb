VersionFilePath = "#{::Rails.root.to_s}/config/version.txt"
raise Exception, "#{ConfigFilePath} configuration file is missing" unless 

Pollit::Application.config.send "version=", if FileTest.exists?(VersionFilePath) then
  IO.read(VersionFilePath)
else
  "Dev"
end
