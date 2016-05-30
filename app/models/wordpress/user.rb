module Wordpress
  class User < WpBase
    self.table_name = "wp_users"

    has_many :posts, foreign_key: :post_author
    has_many :metas, class_name: "Usermeta", foreign_key: "user_id"
  end
end
