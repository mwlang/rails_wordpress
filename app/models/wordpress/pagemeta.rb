module Wordpress
  class Pagemeta < WpBase
    self.table_name = self.prefix_table_name('postmeta')

    belongs_to :page, foreign_key: "post_id"
  end
end
