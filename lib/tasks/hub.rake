namespace :hub do

  desc 'Continuously imports respondents from hub'
  task :import => :environment do
    while true
      HubImporter.import_respondents_for_all
      sleep(Pollit::Application.config.hub_importer_sleep_time || 1800)
    end
  end

end
