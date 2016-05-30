module Wordpress
  class Postmeta < WpBase
    self.table_name = 'wp_postmeta'

    belongs_to :post
  end
end
