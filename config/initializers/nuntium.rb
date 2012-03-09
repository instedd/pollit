class Nuntium
  Config = YAML.load_file(File.expand_path('../../../config/nuntium.yml', __FILE__))[Rails.env] rescue nil

  def self.new_from_config
    Nuntium.new Config['url'], Config['account'], Config['application'], Config['password']
  end

  def self.config
    Config
  end

  def self.authenticate_at_post(user, pass)
    Config['at_post_user'] == user && Config['at_post_pass'] == pass
  end

end
