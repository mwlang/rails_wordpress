require 'rails_helper'

module Wordpress
  RSpec.describe Category, type: :model do
    let(:category) { create(:category, name: "General") }

    it "instantiates" do
      expect(category.name).to eq "General"
      expect(category.slug).to eq "general"
    end
    
    it "finds the category" do
      category
      expect(Category.find_or_create("General")).to eq category
    end
    
    it "creates the category" do 
      category = Category.find_or_create("Big Bang")
      expect(category.slug).to eq "big-bang"
      expect(category.breadcrumbs.map(&:name)).to eq ["Big Bang"]
    end
    
    it "creates a sub_category" do 
      parent = Category.find_or_create("Parent")
      child = Category.find_or_create("Child", parent)
      expect(child.parent_node).to eq parent
      expect(child.parent_node.name).to eq "Parent"
      expect(child.breadcrumbs.map(&:name)).to eq %w(Parent Child)
      expect(parent.sub_categories).to eq [child]
    end
  end
end
