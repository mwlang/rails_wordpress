module Wordpress
  class Page < WpPost
    has_many :metas, class_name: "Pagemeta", foreign_key: "post_id"
  end
end
