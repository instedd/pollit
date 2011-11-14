namespace :gettext do
  namespace :haml do
    desc "Update pot/po files from haml."
    task :find => :environment do
      require 'gettext/tools'
      require 'haml_parser'
      begin
        MY_APP_TEXT_DOMAIN = "mydomain"
        MY_APP_VERSION = Pollit::Application.config.version
        GetText.update_pofiles(MY_APP_TEXT_DOMAIN,
            #Dir.glob("{app/views}/**/*.{haml}"),
            Dir.glob("{app/views}/home/index.{haml}"),
            MY_APP_VERSION,
            :po_root => 'config/locales')
      rescue Exception => e
         puts e
      end
    end
  end
end
