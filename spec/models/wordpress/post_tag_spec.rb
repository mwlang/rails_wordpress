require 'rails_helper'

module Wordpress
  RSpec.describe PostTag, type: :model do
    let(:tag) { create(:tag, name: "Hello Again") }

    it "instantiates" do
      expect(tag.name).to eq "Hello Again"
      expect(tag.slug).to eq "hello-again"
    end
    
    it "finds the tag" do
      tag
      expect(PostTag.find_or_create("Hello Again")).to eq tag
    end
    
    it "creates the tag" do 
      expect(PostTag.find_or_create("Hello, Hello!").slug).to eq "hello-hello"
    end
  end
end
