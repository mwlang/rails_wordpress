require 'rails_helper'

module Wordpress
  RSpec.describe Postmeta, type: :model do
    let(:postmeta) { create(:postmeta, meta_key: "foo", meta_value: "TEST") }
    it "should create foo meta" do
      expect(postmeta.meta_key).to eq "foo"
      expect(postmeta.meta_value).to eq "TEST"
      expect(postmeta.post).to be_kind_of(Post)
      expect(postmeta.post.metas.all).to eq [postmeta]
    end
  end
end
