module Wordpress
  class WpBase < ActiveRecord::Base
    self.abstract_class = true
  end
end
