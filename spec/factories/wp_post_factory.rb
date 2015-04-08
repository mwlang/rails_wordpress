FactoryGirl.define do
  factory :wp_post, class: WordPress::WpPost do
    post_title 'Test'
    post_content 'CONTENT'
    post_excerpt "EXCERPT"
    to_ping "127.0.0.1"
    pinged "127.0.0.1"
    post_content_filtered ""
    association :post_author
  end
end
