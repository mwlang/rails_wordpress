require 'rails_helper'

module WordPress
  RSpec.describe Relationship, type: :model do
    let(:post) { create(:post, :with_tags) }
    let(:first_tag) { post.tags.first }
    let(:second_tag) { post.tags[1] }
    
    it "has tags" do 
      expect(post.tags.count).to eq 2
    end
    
    it "increments counts" do
      expect(first_tag.count).to eq 1
      expect(second_tag.count).to eq 1
    end
    
    it "decrements counts when removed from a post" do 
      first_tag
      second_tag
      post.tags.destroy_all
      first_tag.reload
      second_tag.reload
      expect(first_tag.count).to eq 0
      expect(second_tag.count).to eq 0
    end
    
    it "decrements count when post is deleted" do 
      first_tag
      second_tag
      post.destroy
      first_tag.reload
      second_tag.reload
      expect(first_tag.count).to eq 0
      expect(second_tag.count).to eq 0
    end
  end
end
