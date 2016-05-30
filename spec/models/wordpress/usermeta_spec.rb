require 'rails_helper'

module Wordpress
  RSpec.describe Usermeta, type: :model do
    let(:usermeta) { create(:usermeta, meta_key: "foo", meta_value: "TEST") }
    it "should create foo meta" do
      expect(usermeta.meta_key).to eq "foo"
      expect(usermeta.meta_value).to eq "TEST"
      expect(usermeta.user).to be_kind_of(User)
      expect(usermeta.user.metas.all).to eq [usermeta]
    end
  end
end
