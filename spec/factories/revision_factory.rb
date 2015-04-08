FactoryGirl.define do
  factory :revision, class: WordPress::Revision do 
    post_title 'Revision'
    post_content ""
    post_excerpt ""
    to_ping ""
    pinged ""
    post_content_filtered "'"
    association :post_author
    association :parent
  end
end