require 'rails_helper'

module WordPress
  RSpec.describe Taxonomy, type: :model do
    it "correctly determines STI class" do 
      expect(Taxonomy.find_sti_class("page")).to eq WordPress::Page
    end
    
    it "correctly stores STI class name" do
      expect(WordPress::Post.sti_name).to eq "post"
    end
  end
end
