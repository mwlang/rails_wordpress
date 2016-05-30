FactoryGirl.define do
  factory :option, class: Wordpress::Option do
    option_name "Foobar"
    option_value "Foobar"
    autoload "no"
  end
end
