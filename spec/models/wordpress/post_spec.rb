require 'rails_helper'

module Wordpress
  RSpec.describe Wordpress::Post, type: :model do
    let(:post) { create(:post) }
    let(:new_tag) { create(:tag, {name: "foo#{rand(100)}"}) }
    let(:new_category) { create(:category, name: "Foobar") }
    
    it "sets its meta class correctly" do 
      expect(post).to be_kind_of Wordpress::Post
      expect(post.post_type).to eq "post"
    end

    describe "tags association" do

      it "can add a tag" do
        post.tags << new_tag
        expect(post.tags.count).to eq 1
        expect(post.relationships.count).to eq 1
        expect(post.tags.first.count).to eq 1
      end

      it "can add a named tag" do 
        post.post_tags = "foo, bar"
        post.save
        expect(post.tags.count).to eq 2
      end

    end
    
    describe "categories" do
      it "can add a category" do
        post.categories << new_category
        post.reload
        expect(post.categories.count).to eq 1
        expect(post.categories.last).to eq new_category
        expect(post.categories.last).to be_kind_of Wordpress::Category
      end
      
      it "can add a named category" do 
        post.post_categories = new_category.name
        post.save
        expect(post.categories.all).to eq [new_category]
      end
      
      it "assigns by category id" do 
        post.assign_category_ids [new_category.id]
        post.save
        expect(post.categories.all).to eq [new_category]
      end
      
      it "assigns by category name" do 
        post.assign_category_names [new_category.name]
        post.save
        expect(post.categories.all).to eq [new_category]
      end
      
      it "can add category by id" do 
        post.post_categories = new_category.id
        post.save
        expect(post.categories.all).to eq [new_category]
      end
      
      it "has_category? detects on object and by name" do 
        post.categories << new_category
        post.save
        expect(post.has_category?(new_category.name)).to be true
      end
      
      it "has_category? detects on object and by category" do 
        post.categories << new_category
        post.save
        expect(post.has_category?(new_category)).to be true
      end

      it "revisions preserve categories" do 
        post.post_categories = new_category.id
        post.save
        expect(post.first_revision).to eq post
        new_revision = post.new_revision(:post_categories => "Foo,Bar")
        new_revision.save
        post.reload
        expect(post.post_categories).to eq "Foo,Bar"
      end
    end

    context "without parent" do
      let(:post) { build(:post) }

      it "is valid and can be saved" do
        expect(post.post_parent).to eq 0
        expect(post.parent).to be_nil
        expect(post.save).to eq true
      end
    end
  end
end
