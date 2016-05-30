FactoryGirl.define do
  factory :pagemeta, class: Wordpress::Pagemeta do
    meta_key "foo"
    meta_value "FOO"
    association :page
  end
end
