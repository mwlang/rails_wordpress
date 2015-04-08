module WordPress
  class Category < Taxonomy
    has_many :sub_categories, class_name: "WordPress::Category", foreign_key: :parent, primary_key: :id
    
    def self.cloud
      cats = all.reject{|r| r.posts.empty?}
      total_posts = cats.inject(0){|sum, t| sum += t.count}
      cats.map{|t| {category: t, size: 1.0 + (t.count / total_posts.to_f * 2)}}.sort_by{|sb| sb[:category].slug}
    end
    
    def self.find_or_create category_name, parent = nil
      raise "category name can't be blank" if category_name.blank?
      parent_id = parent.try(:id).to_i
      category = joins(:term).where(wp_terms: {name: category_name}, parent: parent_id).first
      category ||= create!(description: category_name, term_id: Term.create!(name: category_name).id, parent: parent_id)
    end
  end
end
