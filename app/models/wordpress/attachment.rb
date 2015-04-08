module Wordpress
  class Attachment < ActiveRecord::Base
    def default_mime_type
      'image/png'
    end
  end
end
