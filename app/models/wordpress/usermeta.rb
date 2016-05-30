module Wordpress
  class Usermeta < WpBase
    self.primary_key = "umeta_id"
    self.table_name = 'wp_usermeta'

    belongs_to :user
  end
end
