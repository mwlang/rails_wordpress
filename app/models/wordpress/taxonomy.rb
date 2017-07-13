# +------------------+---------------------+------+-----+---------+----------------+
# | Field            | Type                | Null | Key | Default | Extra          |
# +------------------+---------------------+------+-----+---------+----------------+
# | term_taxonomy_id | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
# | term_id          | bigint(20) unsigned | NO   | MUL | 0       |                |
# | taxonomy         | varchar(32)         | NO   | MUL |         |                |
# | description      | longtext            | NO   |     | NULL    |                |
# | parent           | bigint(20) unsigned | NO   |     | 0       |                |
# | count            | bigint(20)          | NO   |     | 0       |                |
# +------------------+---------------------+------+-----+---------+----------------+
module Wordpress
  class Taxonomy < WpBase
    self.table_name = self.prefix_table_name("term_taxonomy")
    self.primary_key = "term_taxonomy_id"
    self.inheritance_column = 'taxonomy'

    def self.find_sti_class type_name
      "wordpress/#{type_name}".camelize.constantize
    end

    def self.sti_name
      name.underscore.split("/").last
    end

    before_create :set_defaults

    has_many :relationships, foreign_key: "term_taxonomy_id"
    has_many :posts, through: :relationships
    has_many :categories, through: :relationships
    has_many :tags, through: :relationships

    has_one :parent_node,
      class_name: "Taxonomy",
      primary_key: :parent,
      foreign_key: :term_taxonomy_id

    has_one :term, foreign_key: "term_id", primary_key: :term_id

    scope :for_cloud, -> { includes(:term).order("count desc").limit(40) }

    delegate :name, :to => :term, :allow_nil => true
    delegate :slug, :to => :term, :allow_nil => true

    def set_defaults
      self.description = '' unless self.description_changed?
    end

    def breadcrumbs
      (parent_node ? [parent_node.breadcrumbs, self] : [self]).flatten
    end

    def title
      [name, description].compact.join(": ")
    end
  end
end
