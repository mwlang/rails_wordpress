FactoryGirl.define do
  factory :post_author, :class => WordPress::User do
    user_login "snoopy"
    user_registered { Time.now }
  end
end