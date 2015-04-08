FactoryGirl.define do
  factory :category, class: WordPress::Category do
    transient do
      name "NAME"
    end
    description { "Describes #{name}" }
    term_id { create(:term, name: name).id }
  end
end
