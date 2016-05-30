require 'rails_helper'

module Wordpress
  RSpec.describe Pagemeta, type: :model do
    let(:pagemeta) { create(:pagemeta, meta_key: "foo", meta_value: "TEST") }
    it "should create foo meta" do
      expect(pagemeta.meta_key).to eq "foo"
      expect(pagemeta.meta_value).to eq "TEST"
      expect(pagemeta.page).to be_kind_of(Page)
      expect(pagemeta.page.metas.all).to eq [pagemeta]
    end
  end
end
