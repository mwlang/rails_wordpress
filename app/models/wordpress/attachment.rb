module Wordpress
  class Attachment < WpPost
    has_many :metas, class_name: "Attachmentmeta", foreign_key: "post_id"
  end
end
