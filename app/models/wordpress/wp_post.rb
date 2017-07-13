module Wordpress
  class WpPost < WpBase
    self.table_name = self.prefix_table_name('posts')
    self.inheritance_column = 'post_type'

    before_create :set_defaults
    before_save :touch_values
    after_save :save_relationships

    scope :published, -> { where(post_status: "publish") }
    scope :descending, -> { order(post_modified: :desc, id: :desc) }
    scope :recent, -> (count = 10) { descending.limit(count) }

    belongs_to :parent, class_name: "Post", foreign_key: "post_parent"

    has_many :relationships, foreign_key: "object_id"
    has_many :tags, class_name: "PostTag", through: :relationships, source: :taxonomy, :dependent => :destroy
    has_many :categories, class_name: "Category", through: :relationships, source: :taxonomy, :dependent => :destroy
    has_many :metas, class_name: "Postmeta", foreign_key: "post_id"

    belongs_to :author, class_name: "User", foreign_key: "post_author"

    def self.find_sti_class type_name
      "wordpress/#{type_name}".camelize.constantize
    end

    def self.sti_name
      name.underscore.split("/").last
    end

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

    def set_defaults
      p = self.parent
      self.author = self.parent.try(:author) || User.first

      self.post_date = (self.parent.try(:post_date) || Time.now) \
        unless self.post_date_changed?

      self.post_date_gmt = (self.parent.try(:post_date_gmt) || self.post_date.utc) \
        unless self.post_date_gmt_changed?

      content = (self.post_content || self.parent.try(:post_content)).to_s
      self.post_excerpt = content.length >= 512 ? "#{content.slice(0, 512)}..." : content \
        unless self.post_content_changed?

      self.to_ping = '' unless self.to_ping_changed?
      self.pinged = '' unless self.pinged_changed?
      self.post_content_filtered = '' unless self.post_content_filtered_changed?
    end

    def first_revision
      self.parent || self
    end

    def touch_values
      self.post_modified = Time.now unless self.post_modified_changed?
      self.post_modified_gmt = self.post_modified.utc  unless self.post_modified_gmt_changed?
      self.post_name = self.post_title.parameterize  unless self.post_name_changed?
    end

    def save_relationships
      return if self.first_revision == self
      self.first_revision.tags.each{|item| item.destroy if item.marked_for_destruction? }
      self.first_revision.categories.each{|item| item.destroy if item.marked_for_destruction? }
      self.first_revision.save
    end

    def tag_names
      first_revision.tags.map(&:name)
    end

    def tag_slugs
      first_revision.tags.map(&:slug)
    end

    def category_names
      first_revision.categories.map(&:name)
    end

    def category_slugs
      first_revision.categories.map(&:slug)
    end

    def created_at
      first_revision.post_date
    end

    def has_category? category
      if category.is_a?(String)
        first_revision.categories.map(&:name).include? category
      else
        first_revision.categories.include? category
      end
    end

    def post_tags
      first_revision.tags.map(&:name).join(",")
    end

    def post_tags= tag_names
      tag_names = tag_names.split(",").map{ |name| name.strip } unless tag_names.is_a?(Array)
      tags_to_assign = tag_names.map{ |tag_name| PostTag.find_or_create(tag_name) }
      new_tags = tags_to_assign.reject{ |tag| first_revision.tags.include?(tag) }

      first_revision.tags.each{ |tag| tag.mark_for_destruction unless tags_to_assign.include?(tag) }
      new_tags.each{ |tag| first_revision.relationships.build(taxonomy: tag) }
    end

    def post_categories
      first_revision.categories.map(&:name).join(",")
    end

    def assign_category_ids category_ids
      categories = category_ids.map{ |id| Category.find(id) rescue nil }.compact
      new_categories = categories.reject{ |category| first_revision.categories.include?(category) }

      first_revision.categories.each{ |cat| cat.mark_for_destruction unless categories.include?(cat) }
      new_categories.each do |category|
        first_revision.relationships.build(taxonomy: category)
      end
    end

    def assign_category_names category_names
      category_ids = category_names.map{ |name| Category.find_or_create(name).id }.compact
      assign_category_ids category_ids
    end

    def post_categories= category_list
      # turn into an array of items unless already so
      unless category_list.is_a?(Array)
        category_list = category_list.to_s.split(",")
          .map{ |name| name.strip }
          .reject{|r| r.blank?}
      end

      # its an array of ids when #to_i => #to_s yields the same
      if category_list.map(&:to_i).map(&:to_s) == category_list
        assign_category_ids category_list
      else
        assign_category_names category_list
      end
    end
  end
end
