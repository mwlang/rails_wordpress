module Wordpress
  class WpPostmeta < WpBase
    self.table_name = 'wp_postmeta'

    belongs_to :post

  end
end
