require 'rails_helper'

module WordPress
  RSpec.describe WordPress::WpPost, type: :model do
    it "instantiates" do 
      expect(create :wp_post).to be_kind_of WordPress::WpPost
    end
  end
end
