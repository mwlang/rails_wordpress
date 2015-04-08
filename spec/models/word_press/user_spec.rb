require 'rails_helper'

module WordPress
  RSpec.describe User, type: :model do
    let(:user) { create :post_author }
    let(:post1) { create :post }
    let(:post2) { create :post }
    
    it "can instantiate" do 
      expect(user.user_login).to eq "snoopy"
    end
    
    it "has an author for a post" do 
      user
      expect(post1.author).to eq user
    end
    
    it "has many posts for the user" do 
      user
      post1
      post2
      expect(user.posts).to eq [post1, post2]
    end
  end
end
