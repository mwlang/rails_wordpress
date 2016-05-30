FactoryGirl.define do
  factory :user, class: Wordpress::User, aliases: [:post_author] do
    user_login 'LOGIN'
    user_pass 'password'
    user_nicename 'NICE NAME'
    user_email 'email@test.local'
    user_url "users/test"
    user_registered { Time.now }
    user_activation_key 'ACTIVATIONKEY'
    user_status 0
    display_name 'DISPLAY NAME'
  end
end
