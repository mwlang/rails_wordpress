FactoryGirl.define do
  factory :usermeta, class: Wordpress::Usermeta do
    meta_key "foo"
    meta_value "FOO"
    association :user
  end
end
