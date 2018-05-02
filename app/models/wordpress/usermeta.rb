module Wordpress
  class Usermeta < WpBase
    self.primary_key = "umeta_id"
    self.table_name = self.prefix_table_name('usermeta')

    belongs_to :user, optional: true
  end
end
