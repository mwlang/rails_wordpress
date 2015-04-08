require 'rails_helper'

module WordPress
  RSpec.describe WordPress::Page, type: :model do
    let(:page) { create(:page) }
    let(:new_tag) { create(:tag, {name: "foo#{rand(100)}"}) }

    it "sets its meta class correctly" do 
      expect(page).to be_kind_of WordPress::Page
      expect(page.post_type).to eq "page"
    end

    describe "tags association" do

      it "can add a tag" do
        page.tags << new_tag
        expect(page.tags.count).to eq 1
        expect(page.relationships.count).to eq 1
        expect(page.tags.first.count).to eq 1
      end

      it "can add a named tag" do 
        page.post_tags = "foo, bar"
        page.save
        expect(page.tags.count).to eq 2
      end

    end
    
  end
end
