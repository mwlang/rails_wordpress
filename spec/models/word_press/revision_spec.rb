require 'rails_helper'

module WordPress
  RSpec.describe Revision, type: :model do
    let(:post) { create(:post) }
    let(:revision) { post.new_revision.tap{ |r| r.save } }

    it "sets its meta class correctly" do 
      expect(revision).to be_kind_of WordPress::Revision
      expect(revision.post_type).to eq "revision"
    end

    let(:params) { {} }
    let(:new_revision) { post.new_revision params }
    let(:new_content) { "Revised Content" }
    let(:another_excerpt) { "ANOTHER EXCERPT..." }
    
    it "should be a revision" do
      expect(new_revision).to be_kind_of WordPress::Revision
    end

    it "is a new record" do
      expect(new_revision.new_record?).to be true
    end

    it "belongs to parent" do
      new_revision.save
      expect(post.revisions.all).to eq [new_revision]
    end

    describe "two revisions" do 
      let(:params) { { post_content: new_content } }

      subject do 
        post.update_attributes(post_date: Date.civil(2009,1,1), post_modified: Date.civil(2010,1,1))
        new_revision.save
        post.new_revision({ post_excerpt: "ANOTHER" }).save
        post.reload
        post
      end
      its(:content) { should eq new_content }
      its(:excerpt) { should eq "ANOTHER" }
    end

    describe "parameters" do 
      let(:params) { { post_content: new_content } }

      it "should have revised content" do 
        expect(new_revision.post_content).to eq new_content
      end

      it "should not reflect in the post until saved" do
        expect(post.content).to eq "CONTENT"
        new_revision.save
        expect(post.content).to eq new_content
      end

      it "should update the post_modified date" do
        post.update_attributes(post_date: Date.civil(2009,1,1), post_modified: Date.civil(2010,1,1))
        post.reload
        expect(post.created_at.year).to eq 2009
        expect(post.updated_at.year).to eq 2010
        new_revision.save
        expect(post.created_at.year).to eq 2009
        expect(post.updated_at.year).to eq Date.today.year
      end

      it "defaults post_name to a revision" do
        new_revision.save
        expect(post.latest_revision.post_name).to eq "#{post.id}-revision-v1"
      end

      describe "latest_revision" do 
        subject do 
          post.update_attributes(post_date: Date.civil(2009,1,1), post_modified: Date.civil(2010,1,1))
          new_revision.save 
          post 
        end

        its(:title) { should eq new_revision.post_title }
        its("updated_at.year") { should eq Date.today.year }
        its("content") { should eq new_content }
        its("created_at.year") { should eq 2009 }
      end
    end
  end
end
