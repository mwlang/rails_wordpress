module Wordpress
  class PostTag < Taxonomy
    def self.cloud
      tags_for_cloud = for_cloud.all
      total_tags = tags_for_cloud.inject(0){|sum, t| sum += t.count}
      tags_for_cloud.map{|t| {tag: t, size: 1.0 + (t.count / total_tags.to_f * 5)}}.sort_by{|sb| sb[:tag].slug}
    end

    def self.find_or_create tag_name
      raise "tag name can't be blank" if tag_name.blank?
      joins(:term).where(wp_terms: {name: tag_name}).first || create!(term_id: Term.create!(name: tag_name).id)
    end
  end
end
