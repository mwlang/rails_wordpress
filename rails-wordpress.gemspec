$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "word_press/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-wordpress"
  s.version     = WordPress::VERSION
  s.authors     = ["mwlang"]
  s.email       = ["mwlang@cybrains.net"]
  s.homepage    = "http://github.com/mwlang/rails-wordpress"
  s.summary     = "A Rails Engine to connect to WordPress tables with ActiveRecord modeling"
  s.description = "This Engine allows you to easily wire up a Rails app to an existing WordPress database"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "mysql2"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'factory_girl', "~> 4.5.0"

  s.add_development_dependency "guard-rails"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "database_cleaner"
end
