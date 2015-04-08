require 'rails_helper'

module Wordpress
  RSpec.describe Taxonomy, type: :model do
    it "correctly determines STI class" do 
      expect(Taxonomy.find_sti_class("page")).to eq Wordpress::Page
    end
    
    it "correctly stores STI class name" do
      expect(Wordpress::Post.sti_name).to eq "post"
    end
  end
end
