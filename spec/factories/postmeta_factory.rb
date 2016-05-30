FactoryGirl.define do
  factory :postmeta, class: Wordpress::Postmeta do
    meta_key "foo"
    meta_value "FOO"
    association :post
  end
end
