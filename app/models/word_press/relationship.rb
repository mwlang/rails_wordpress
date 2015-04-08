# +------------------+---------------------+------+-----+---------+-------+
# | Field            | Type                | Null | Key | Default | Extra |
# +------------------+---------------------+------+-----+---------+-------+
# | object_id        | bigint(20) unsigned | NO   | PRI | 0       |       |
# | term_taxonomy_id | bigint(20) unsigned | NO   | PRI | 0       |       |
# | term_order       | int(11)             | NO   |     | 0       |       |
# +------------------+---------------------+------+-----+---------+-------+
module WordPress
  class Relationship < ActiveRecord::Base
    self.table_name = "wp_term_relationships"
    self.primary_key = nil
    after_save :increment_term_use_count
    before_destroy :decrement_term_use_count

    belongs_to :post, class_name: "WordPress::Post", foreign_key: "object_id"
    belongs_to :taxonomy, class_name: "WordPress::Taxonomy", foreign_key: "term_taxonomy_id"

    def increment_term_use_count
      self.taxonomy.update_attribute(:count, self.taxonomy.count + 1) if self.taxonomy.present?
    end

    def decrement_term_use_count
      self.taxonomy.update_attribute(:count, self.taxonomy.count - 1) if self.taxonomy.present?
    end
  end
end
