$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_wordpress/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_wordpress"
  s.version     = Wordpress::VERSION
  s.authors     = ["Michael Lang"]
  s.email       = ["mwlang@cybrains.net"]
  s.homepage    = "https://github.com/mwlang/rails_wordpress"
  s.summary     = "A Rails Engine to connect to Wordpress tables with ActiveRecord modeling"
  s.description = "A Rails Engine that enables you to easily wire up a Rails app to an existing Wordpress database"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc", "Guardfile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2"

  s.add_development_dependency "mysql2", "~> 0.3"
  s.add_development_dependency 'rspec-rails', "~> 3.2"
  s.add_development_dependency 'rspec-its', "~> 1.2"
  s.add_development_dependency 'factory_girl', "~> 4.5"

  s.add_development_dependency "guard-rails", "~> 0.7"
  s.add_development_dependency "guard-rspec", "~> 4.5"
  s.add_development_dependency "database_cleaner", "~> 1.4"
end
