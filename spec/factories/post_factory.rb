FactoryGirl.define do
  factory :post, class: WordPress::Post do 
    post_title 'Test'
    post_content 'CONTENT'
    post_excerpt "EXCERPT"
    to_ping "127.0.0.1"
    pinged "127.0.0.1"
    post_content_filtered "'"
    association :post_author
    
    trait :with_tags do 
      after(:create) do |post, evaluator|
        create(:relationship, post: post, taxonomy: create(:tag, name: "Foo"))
        create(:relationship, post: post, taxonomy: create(:tag, name: "Bar"))
      end
    end
    
  end
end
