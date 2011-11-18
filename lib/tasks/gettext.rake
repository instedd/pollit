namespace :gettext do
  namespace :find do
    desc "Update pot/po files with haml support."
    task :all => :environment do
      require 'gettext/tools'
      require 'haml_parser'
      begin
        GetText.update_pofiles(FastGettext.default_text_domain,
            Dir.glob("{app}/**/*.{haml,rb,erb}"),
            Pollit::Application.config.version,
            :po_root => 'config/locales')
      rescue Exception => e
         puts e
      end
    end
  end
end
