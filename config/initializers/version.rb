VersionFilePath = "#{::Rails.root.to_s}/config/version.txt"
raise Exception, "#{ConfigFilePath} configuration file is missing" unless 

if FileTest.exists?(VersionFilePath)  
  Pollit::Application.config.send("version=", IO.read(VersionFilePath))
else
  Pollit::Application.config.send("version=", "Dev")
end
