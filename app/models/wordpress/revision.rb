module Wordpress
  class Revision < WpPost
    scope :exclude_autosaves, -> { where("post_name NOT LIKE '%autosave%'") }
  end
end
