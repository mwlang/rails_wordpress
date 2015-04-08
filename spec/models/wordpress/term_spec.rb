require 'rails_helper'

module Wordpress
  RSpec.describe Term, type: :model do
    let(:term) { create(:term, name: "Hello") }
    it "should create hello term" do
      expect(term.name).to eq "Hello"
      expect(term.slug).to eq "hello"
    end
  end
end
