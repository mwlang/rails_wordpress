module Wordpress
  class Pagemeta < WpBase
    self.table_name = 'wp_postmeta'

    belongs_to :page, foreign_key: "post_id"
  end
end
