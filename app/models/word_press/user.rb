module WordPress
  class User < ActiveRecord::Base
    self.table_name = "wp_users"
  end
end
