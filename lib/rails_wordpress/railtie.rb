module Wordpress
  class Railtie < ::Rails::Railtie
    initializer :wordpress do |app|
      if Rails::VERSION::MAJOR >= 5
        options = app.config.active_record
        options.belongs_to_required_by_default = false

        ActiveSupport.on_load(:active_record) do
          options.each { |k,v| send("#{k}=", v) }
        end
      end
    end
  end
end
