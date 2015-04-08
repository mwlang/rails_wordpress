module WordPress
  class Post < WpPost
    has_many :revisions, class_name: "Revision", foreign_key: "post_parent"

    def new_revision params = {}
      result = self.revisions.new \
        post_author: self.post_author,
        post_date: self.post_date,
        post_date_gmt: self.post_date_gmt,
        post_content: (params[:post_content] || self.content),
        post_title: (params[:post_title] || self.title),
        post_excerpt: (params[:post_excerpt] || self.excerpt),
        post_status: 'inherit',
        ping_status: (self.ping_status || 'closed'),
        post_password: '',
        post_name: "#{self.id}-revision-v#{self.revisions.count + 1}",
        to_ping: self.to_ping,
        pinged: self.to_ping,
        post_modified: Time.now,
        post_modified_gmt: Time.now.utc,
        post_content_filtered: '',
        guid: SecureRandom.uuid,
        menu_order: self.menu_order,
        post_mime_type: '',
        comment_count: 0

      result.post_tags = params[:post_tags] if params[:post_tags]
      result.post_categories = params[:post_categories] if params[:post_categories]
      result
    end
    
    def latest_revision
      revisions.descending.first || self
    end

    def title
      latest_revision.post_title
    end

    def content
      latest_revision.post_content
    end

    def excerpt
      latest_revision.post_excerpt
    end
    
    def created_at
      self.post_date
    end
    
    def updated_at
      latest_revision.post_modified
    end
    
  end
end
