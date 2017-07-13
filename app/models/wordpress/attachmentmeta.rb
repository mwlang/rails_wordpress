module Wordpress
  class Attachmentmeta < WpBase
    self.table_name = self.prefix_table_name('postmeta')

    belongs_to :attachment, foreign_key: "post_id", class_name: "Attachment"
  end
end
