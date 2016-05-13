module Wordpress
  class Post < WpPost
    validates :post_title, presence: true
  end
end
