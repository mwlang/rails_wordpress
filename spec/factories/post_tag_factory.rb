FactoryGirl.define do
  factory :tag, class: WordPress::PostTag do
    transient do
      name "NAME"
    end
    description { "Describes #{name}" }
    term_id { create(:term, name: name).id }
  end
end
