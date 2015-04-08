FactoryGirl.define do
  factory :attachment, class: Wordpress::Attachment do 
    post_title 'Attachment'
    post_content ""
    post_excerpt ""
    to_ping ""
    pinged ""
    post_content_filtered "'"
    association :post_author
  end
end
