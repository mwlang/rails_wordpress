# Rails WordPress

This is a WordPress Engine for Rails 4.x.  It provides ActiveRecord models that directly utilize WordPress' tables.  The model classes have been named for the most part according to typical Rails naming convention and model the actual underlying WordPress concepts.  For example, wp_posts contains posts, pages, attachments, revisions, links, and many other meta types.  This engine models the most common ones: WordPress::Post, WordPress::Page, WordPress::Revision, etc..

### Project Status

The current state of this project is ALPHA and not everything is modeled, but there is solid implementation for posts, revisions, categories, and tags that will allow you to rapidly build a Rails-based blog or view on an active WordPress site that you have access to the database.  

This engine is *not* providing API/RESTFul connections to a WordPress site.  It is a direct tie-in to the WordPress database with functionality reverse-engineered via ActiveRecord models.

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

## ActiveRecord Models

The following ActiveRecord models are available via this Engine:

### WordPress::Post

This model is the main model you're probably interested in.  It models WordPress Posts, Revisions, Tags, and Categories  WordPress has a somewhat complicated Post + Revision system.  I did not attempt to verify all functionality implemented by its Revision system -- however, I did get the logic working well enough for my needs.  Basically, tags, categories, etc. are assumed to be linked against the original wp_posts::post_type => 'post' and when multiple revisions on a post exists, any edits to the tags and categories are saved against the first post's record, not the latest revision record that is created.  From what I could tell, all of my posts were correctly rendered on my personal blog with this approach.

As it is, you can emulate WordPress' revision system succinctly with the following controller examples:

``` ruby
def new
  @post = WordPress::Post.new
end

# Simply call #save on the newly created post
def create
  begin
    @post = WordPress::Post.new(post_params)
    @post.save!
    redirect_to post_path(@post), notice: 'Post was successfully created.'
  rescue
    render action: 'new'
  end
end

# This is an example of how to "revert" to an earlier version of the post
def revert
  revision = WordPress::Revision.find(params[:id])
  revision.update_attribute(:post_modified, Time.now)
  redirect_to edit_post_path(revision.parent)
end

# Note the use of "new_revision" against the post to save!
def update
  begin
    @post.new_revision(post_params).save!
    redirect_to post_path(@post), notice: 'Post was successfully updated.'
  rescue
    render action: 'edit'
  end
end

def set_post
  @post = WordPress::Post.find(params[:id])
  @title = @post.title
end

def post_params
  params[:post].permit(:post_title, :post_content, :post_excerpt, :post_tags, :post_categories => [])
end

```

The following scopes are available on WordPress::Post

* WordPress::Post.recent => The first 10 posts ordered by date modified for the post
* WordPress::Post.recent(N) => The first N posts ordered by date modified for the post
* WordPress::Post.published => All posts in published status
* WordPress::Post.descending => Orders posts by post_modified date in descending order

An example showing last 5 posts published:

```
@recent_posts = WordPress::Post.published.recent(5)
```

The following are also available on a given post (@post = WordPress::Post.first):

* @post.first_revision => The first (a.k.a. parent) record for this post.  Relevant only to WordPress::Revision in this case
* @post.author => instance of WordPress::User and is the person that authored the post
* @post.created_at => alias of the @post.first_revision.post_date
* @post.categories => a collection of WordPress::Category
* @post.tags => a collection of WordPress::PostTag

### Assigning Tags

Tags can be assigned to a post by setting up your form with post_tags field that contains the tags in comma delimited format.  I had good success using the [Tagit Gem](https://rubygems.org/gems/tagit) along with permitting the parameter per the above Controller example.

WordPress::Post#post_tags= can take either a comma delimited list of tags or an array of strings, each item being a tag's name.

Some examples for tags:

```
post = WordPress::Post.published.first
post.tag_names # => ["Ruby Language", "Rails"]
post.post_tags = "Ruby,Rails,Rails 4" # => Creates the new "Rails 4" tag and associates to the post record.

# The following creates a new revision of the post, copying most of the fields, updating others appropriate. 
# It also removes the above tags and assigns just "Foobar" tag to the post

post.new_revision(:post_tags => ["Foobar"]).save!
```

### Assigning Categories

Categories can be assigned to a post by setting up your form with post_categories[].  I found it better to set up checkbox fields with the WordPress::Category#id than with WordPress::Category#name as Categories are hierarchically arranged and I had some categories with the same name.

WordPress::Post#post_categories= can take any of the following:

* A comma separated string representing a list of category names
* A comma separated string representing a list of category ids
* An array of String with each element being a category name
* An array of String or Fixnum with each element being a category's ID

Some examples for categories:

```
foobar_category = WordPress::Category.find_or_create("Foobar") # a top-level category
sub_category = WordPress::Category.find_or_create("Foo", foobar_category) # A sub-category of "Foobar"

post.categories << foobar_category # assigns the "Foobar" category to the post
post.post_categories = [foobar_category.id, sub_category.id] # assigns "Foobar" and "Foo" categories to the post.
```

The presence of Revisions complicates checking if a post belongs to specific categories.  If you are holding an instance of a WordPress::Revision instead of WordPress::Post, then @post.categories.include?(some_category) will fail because the relationship is maintained off the original WordPress::Post record. To check if a post is in a category, use has_category? as follows:

```
# continuing above examples...
post.save!
post.has_category? foobar_category # => true 

new_revision = post.new_revision(:post_categories => "Foobar, Foo")
new_revision.save!
post.reload
post.has_category?("Foobar") # => true
new_revision.category_names # => "Foobar, Foo"
new_revision.has_category?("Foo") # => true
```

### WordPress::Page

This model is functionally similar to the WordPress::Post model, but for WordPress Pages where wp_posts::post_type => 'page'

### WordPress:Category

This model represents a hierarchical organization of categories and is an abstraction of WordPress' complicated mess of wp_term_taxonomy, wp_terms, and ultimately linked to wp_posts through wp_term_relationships.  Categories are distinguished on the wp_term_taxonomy::taxonomy field containing "category" for it's field value.

Simply put, to get a category use WordPress::Category.  This is also what's returned for a given post's #categories association which a has_many :through :relationships association.

The WordPress::Category model has two class-level convenience methods:

WordPress::Category#cloud returns a hash of the categories and a bit of math to calculate size/importance of the category (basically number of times a category is assigned to a post relative to number of other category assignments).  For example:

``` ruby
WordPress::Category.cloud 
        # => [{:category=>
        #    #<WordPress::Category:0x007ff349959108
        #     term_taxonomy_id: 75,
        #     term_id: 70,
        #     count: 1>,
        #   :size=>1.0240963855421688},
        #  {:category=>
        #    #<WordPress::Category:0x007ff349958780
        #     term_taxonomy_id: 76,
        #     term_id: 71,
        #     count: 3>,
        #   :size=>1.072289156626506},
        #  {:category=>
        #    #<WordPress::Category:0x007ff349969288
        #     term_taxonomy_id: 5,
        #     term_id: 5,
        #     count: 1>,
        #   :size=>1.0240963855421688},
        #    .
        #    .
        #    .
        # ]
```
An HAML example for rendering the Category cloud:

``` haml
%h2 Categories
- WordPress::Category.cloud.each do |t| 
  = link_to t[:category].name, category_path(t[:category]), style: "font-size: #{t[:size]}em" 
  %br
```

`WordPress::Category#find_or_create category_name, parent = 0` makes it super easy to find or create a new category by name under the appropriate parent node.  The top-level categories all have parent_id = 0 (instead of NULL).  If you want a category created as a sub-category, simply pass the parent category along.  For example:

``` ruby
foobar_category = WordPress::Category.find_or_create("Foobar") # a top-level category
sub_category = WordPress::Category.find_or_create("Foo", foobar_category) # A sub-category of "Foobar"
```

### WordPress::PostTag

The PostTag class works similar to the Category class, but for "post_tag" taxonomy types.  Like Category's class-level methods, there is likewise a WordPress::PostTag#cloud and WordPress::PostTag#find_or_create methods to facilitate tagging.  PostTags are not hierarchical and the parent_id is always zero.

An HAML example for rendering Tag cloud:

``` haml
%h2 Tags
%div{style: 'margin-left: 25%'}
  - tags = WordPress::PostTag.cloud.map{ |t| link_to t[:tag].name, tag_path(t[:tag]), style: "font-size: #{t[:size]}em" }
  = tags.join(" &middot; ").html_safe
```

NOTE: post_path, tag_path, category_path, etc. all must be appropriately defined in your config/routes.rb file.


### License

This project rocks and uses MIT-LICENSE.