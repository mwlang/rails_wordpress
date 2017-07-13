module Wordpress
  class WpBase < ActiveRecord::Base
    self.abstract_class = true

    def self.prefix_table_name table_name
      prefix ||= self.connection_config[:prefix] || "wp"
      "#{prefix}_#{table_name}"
    end
  end
end
