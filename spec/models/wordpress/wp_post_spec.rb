require 'rails_helper'

module Wordpress
  RSpec.describe Wordpress::WpPost, type: :model do
    it "instantiates" do 
      expect(create :wp_post).to be_kind_of Wordpress::WpPost
    end
  end
end
