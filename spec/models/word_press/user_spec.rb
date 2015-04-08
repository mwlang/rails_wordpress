require 'rails_helper'

module WordPress
  RSpec.describe User, type: :model do
    let(:user) { create :post_author }
    it "can instantiate" do 
      expect(user.user_login).to eq "snoopy"
    end
  end
end
