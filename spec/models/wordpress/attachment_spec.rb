require 'rails_helper'

module Wordpress
  RSpec.describe Wordpress::Attachment, type: :model do
    let(:attachment) { create(:attachment) }
    let(:new_tag) { create(:tag, {name: "foo#{rand(100)}"}) }
    let(:new_category) { create(:category, name: "Foobar") }

    it "sets its meta class correctly" do
      expect(attachment).to be_kind_of Wordpress::Attachment
      expect(attachment.post_type).to eq "attachment"
    end

    describe "tags association" do

      it "can add a tag" do
        attachment.tags << new_tag
        expect(attachment.tags.count).to eq 1
        expect(attachment.relationships.count).to eq 1
        expect(attachment.tags.first.count).to eq 1
      end

      it "can add a named tag" do
        attachment.post_tags = "foo, bar"
        attachment.save
        expect(attachment.tags.count).to eq 2
      end

    end

    describe "categories" do
      it "can add a category" do
        attachment.categories << new_category
        attachment.reload
        expect(attachment.categories.count).to eq 1
        expect(attachment.categories.last).to eq new_category
        expect(attachment.categories.last).to be_kind_of Wordpress::Category
      end
    end

  end
end
