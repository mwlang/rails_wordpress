module Wordpress
  class Attachment < WpPost
    def default_mime_type
      'image/png'
    end
  end
end
