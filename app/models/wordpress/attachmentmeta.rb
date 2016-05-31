module Wordpress
  class Attachmentmeta < WpBase
    self.table_name = 'wp_postmeta'

    belongs_to :attachment, foreign_key: "post_id", class_name: "Attachment"
  end
end
