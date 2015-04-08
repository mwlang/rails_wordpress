# Rails WordPress

This is a WordPress Engine for Rails 4.x.  It provides ActiveRecord models that directly utilize WordPress' tables.  The model classes have been named for the most part according to typical Rails naming convention and model the actual underlying WordPress concepts.  For example, wp_posts contains posts, revisions, links, and many other meta types.  This engine models the most common ones: WordPress::Post, WordPress::Revision, etc..

### Project Status

The current state of this project is ALPHA and not everything is modeled, but there is solid implementation for posts, revisions, categories, and tags that will allow you to rapidly build a Rails-based blog or view on an active WordPress site that you have access to the database.  

This engine is *not* providing API/RESTFul connections to a WordPress site.  It is a direct tie-in to the WordPress database with functionality reverse-engineered into ActiveRecord models.

This engine is currently in production use and being utilized in my blog at http://codeconnoisseur.org

This Engine was developed and tested with Rails 4.2, but should work for all 4.x and up.  Because WordPress is MySQL based, this engine expects MySQL as a dependency.  If you have converted your WordPress to another DBMS and adapt this gem accordingly, then Pull Requests complete with unit tests are welcome!

## How to Use

In your Rails Gemfile add the gem: 

```
gem 'rails-wordpress'
```

and then: 

```
bundle install
```

### License

This project rocks and uses MIT-LICENSE.