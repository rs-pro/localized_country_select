require 'localized_country_select'

module LocalizedCountrySelect
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '..', '..', 'locale', '*.{rb,yml}') ]
      rake_tasks do
        load "tasks/localized_country_select_tasks.rake"
      end
    end
  end
end
