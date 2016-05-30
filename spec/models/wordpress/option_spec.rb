require 'rails_helper'

module Wordpress
  RSpec.describe Option, type: :model do
    let(:option) { create(:option, option_name: "Hello", option_value: "World") }
    it "should create hello option" do
      expect(option.option_name).to eq "Hello"
      expect(option.option_value).to eq "World"
      expect(option.id).to eq option.option_id
    end
  end
end
