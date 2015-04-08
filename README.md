# Rails Wordpress

This is a Wordpress Engine for Rails 4.x.  It provides ActiveRecord models that directly utilize Wordpress' tables.  The model classes have been named for the most part according to typical Rails naming convention and model the actual underlying Wordpress concepts.  For example, wp_posts contains posts, pages, attachments, revisions, links, and many other meta types.  This engine models the most common ones: Wordpress::Post, Wordpress::Page, Wordpress::Revision, etc..

### Project Status

The current state of this project is ALPHA and not everything is modeled, but there is solid implementation for posts, revisions, categories, and tags that will allow you to rapidly build a Rails-based blog or view on an active Wordpress site that you have access to the database.  

This engine is a direct tie-in to the Wordpress database with functionality reverse-engineered via ActiveRecord models.  

This engine (presently) does *not* provide API/RESTFul connections to a Wordpress site nor Rails Views and View Helpers.

This engine is currently in production use and being utilized in my blog at http://codeconnoisseur.org

This Engine was developed and tested with Rails 4.2, but should work for all 4.x and up.  Because Wordpress is MySQL based, this engine expects MySQL as a dependency.  If you have converted your Wordpress to another DBMS and adapt this gem accordingly, then Pull Requests complete with unit tests are welcome!

## How to Use

In your Rails Gemfile add the gem: 

```
gem 'rails_wordpress'
```

and then: 

```
bundle install
```

## ActiveRecord Models

The following ActiveRecord models are available via this Engine:

### Wordpress::Post

This model is the main model you're probably interested in.  It models Wordpress Posts, Revisions, Tags, and Categories  Wordpress has a somewhat complicated Post + Revision system.  I did not attempt to verify all functionality implemented by its Revision system -- however, I did get the logic working well enough for my needs.  Basically, tags, categories, etc. are assumed to be linked against the original wp_posts::post_type => 'post' and when multiple revisions on a post exists, any edits to the tags and categories are saved against the first post's record, not the latest revision record that is created.  From what I could tell, all of my posts were correctly rendered on my personal blog with this approach.

As it is, you can emulate Wordpress' revision system succinctly with the following controller examples:

``` ruby
def new
  @post = Wordpress::Post.new
end

# Simply call #save on the newly created post
def create
  begin
    @post = Wordpress::Post.new(post_params)
    @post.save!
    redirect_to post_path(@post), notice: 'Post was successfully created.'
  rescue
    render action: 'new'
  end
end

# This is an example of how to "revert" to an earlier version of the post
def revert
  revision = Wordpress::Revision.find(params[:id])
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
  @post = Wordpress::Post.find(params[:id])
  @title = @post.title
end

def post_params
  params[:post].permit(:post_title, :post_content, :post_excerpt, :post_tags, :post_categories => [])
end
```

The following scopes are available on Wordpress::Post

* Wordpress::Post.recent => The first 10 posts ordered by date modified for the post
* Wordpress::Post.recent(N) => The first N posts ordered by date modified for the post
* Wordpress::Post.published => All posts in published status
* Wordpress::Post.descending => Orders posts by post_modified date in descending order

An example showing last 5 posts published:

``` ruby
@recent_posts = Wordpress::Post.published.recent(5)
```

The following are also available on a given post (@post = Wordpress::Post.first):

* @post.first_revision => The first (a.k.a. parent) record for this post.  Relevant only to Wordpress::Revision in this case
* @post.latest_revision => The most recently saved revision of the post (may be either self or a Wordpress::Revision instance)
* @post.author => instance of Wordpress::User and is the person that authored the post
* @post.created_at => alias of the @post.first_revision.post_date
* @post.categories => a collection of Wordpress::Category
* @post.category_names => an array of category names
* @post.tags => a collection of Wordpress::PostTag
* @post.tag_names => an array of tag names

Remember that Wordpress::Revision often contains newer data than Wordpress::Post because of Wordpress' way of maintaining revisions.  When rendering your views, use these properties to ensure latest data is displayed:

* @post.content => self.latest_revision.post_content or self.post_content
* @post.excerpt => self.latest_revision.post_excerpt or self.post_excerpt
* @post.title => self.latest_revision.post_title or self.post_title 
* @post.updated_at => latest_revision.post_modified
* @post.created_at => first_revision.post_created
* @post.post_tags => first_revision.tags
* @post.post_categories => first_revision.categories

The above will work seamlessly with either a Wordpress::Post or Wordpress::Revision instance.  

When you want to edit a Post, you'll likely want to edit against the latest revision rather than the first revision. You can do one of two strategies:

1. Pass the original Post (@post.first_revision) to the form_for helper, but populate using form_tag helpers from the @post.latest_revision (or whichever revision you opt to load).  In the controller, @post = Wordpress::Post.find(params[:id]) followed by @post.new_revision(post_params).save
1. Pass the latest Revision (@revision or @post.last_revision) to the form_for helper.  In the controller @revision = Wordpress::Revision.find(params[:id]) followed by @revision.new_revision(post_params).save

### Assigning Tags

Tags can be assigned to a post by setting up your form with post_tags field that contains the tags in comma delimited format.  I had good success using the [Tagit Gem](https://rubygems.org/gems/tagit) along with permitting the parameter per the above Controller example.

Wordpress::Post#post_tags= can take either a comma delimited list of tags or an array of strings, each item being a tag's name.

Some examples for tags:

``` ruby
post = Wordpress::Post.published.first
post.tag_names # => ["Ruby Language", "Rails"]
post.post_tags = "Ruby,Rails,Rails 4" # => Creates the new "Rails 4" tag and associates to the post record.

# The following creates a new revision of the post, copying most of the fields, updating others appropriate. 
# It also removes the above tags and assigns just "Foobar" tag to the post
post.new_revision(:post_tags => ["Foobar"]).save!
```

### Assigning Categories

Categories can be assigned to a post by setting up your form with post_categories[].  I found it better to set up checkbox fields with the Wordpress::Category#id than with Wordpress::Category#name as Categories are hierarchically arranged and I had some categories with the same name.

Wordpress::Post#post_categories= can take any of the following:

* A comma separated string representing a list of category names
* A comma separated string representing a list of category ids
* An array of String with each element being a category name
* An array of String or Fixnum with each element being a category's ID

Some examples for categories:

``` ruby
foobar_category = Wordpress::Category.find_or_create("Foobar") # a top-level category
sub_category = Wordpress::Category.find_or_create("Foo", foobar_category) # A sub-category of "Foobar"

post.categories << foobar_category # assigns the "Foobar" category to the post
post.post_categories = [foobar_category.id, sub_category.id] # assigns "Foobar" and "Foo" categories to the post.
```

The presence of Revisions complicates checking if a post belongs to specific categories.  If you are holding an instance of a Wordpress::Revision instead of Wordpress::Post, then @post.categories.include?(some_category) will fail because the relationship is maintained off the original Wordpress::Post record. To check if a post is in a category, use has_category? as follows:

``` ruby
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

### Wordpress::Page

This model is functionally similar to the Wordpress::Post model, but for Wordpress Pages where wp_posts::post_type => 'page'

### Wordpress:Category

This model represents a hierarchical organization of categories and is an abstraction of Wordpress' complicated mess of wp_term_taxonomy, wp_terms, and ultimately linked to wp_posts through wp_term_relationships.  Categories are distinguished on the wp_term_taxonomy::taxonomy field containing "category" for it's field value.

Simply put, to get a category use Wordpress::Category.  This is also what's returned for a given post's #categories association which a has_many :through :relationships association.

The Wordpress::Category model has two class-level convenience methods:

Wordpress::Category#cloud returns a hash of the categories and a bit of math to calculate size/importance of the category (basically number of times a category is assigned to a post relative to number of other category assignments).  For example:

``` ruby
Wordpress::Category.cloud 
        # => [{:category=>
        #    #<Wordpress::Category:0x007ff349959108
        #     term_taxonomy_id: 75,
        #     term_id: 70,
        #     count: 1>,
        #   :size=>1.0240963855421688},
        #  {:category=>
        #    #<Wordpress::Category:0x007ff349958780
        #     term_taxonomy_id: 76,
        #     term_id: 71,
        #     count: 3>,
        #   :size=>1.072289156626506},
        #  {:category=>
        #    #<Wordpress::Category:0x007ff349969288
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
- Wordpress::Category.cloud.each do |t| 
  = link_to t[:category].name, category_path(t[:category]), style: "font-size: #{t[:size]}em" 
  %br
```

`Wordpress::Category#find_or_create category_name, parent = 0` makes it super easy to find or create a new category by name under the appropriate parent node.  The top-level categories all have parent_id = 0 (instead of NULL).  If you want a category created as a sub-category, simply pass the parent category along.  For example:

``` ruby
foobar_category = Wordpress::Category.find_or_create("Foobar") # a top-level category
sub_category = Wordpress::Category.find_or_create("Foo", foobar_category) # A sub-category of "Foobar"
```

You can also recursively navigate through sub_categories like so:

``` haml
# ~/app/views/posts/edit.html.haml
= form_for @post do |f|
    %label Title
    = f.text_field :post_title, class: "form-control input-sm"

    %label Content
    = f.text_area :post_content, class: "form-control input-sm hidden"

    %label Categories
    = render 'categories', categories: Wordpress::Category.all
    
    = f.submit 'Save', class: "btn"
```

``` haml
# ~/app/views/posts/_categories.html.haml
%ul
  - categories.each do |category|
    %li
      = check_box :post, :post_categories, {multiple: true, checked: @post.has_category?(category)}, category.id, nil
      = category.name
      - unless category.sub_categories.empty?
        = render 'dashboard/categories', categories: category.sub_categories
```

### Wordpress::PostTag

The PostTag class works similar to the Category class, but for "post_tag" taxonomy types.  Like Category's class-level methods, there is likewise a Wordpress::PostTag#cloud and Wordpress::PostTag#find_or_create methods to facilitate tagging.  PostTags are not hierarchical and the parent_id is always zero.

An HAML example for rendering Tag cloud:

``` haml
%h2 Tags
%div{style: 'margin-left: 25%'}
  - tags = Wordpress::PostTag.cloud.map{ |t| link_to t[:tag].name, tag_path(t[:tag]), style: "font-size: #{t[:size]}em" }
  = tags.join(" &middot; ").html_safe
```

NOTE: post_path, tag_path, category_path, etc. all must be appropriately defined in your config/routes.rb file.

### Wordpress::Taxonomy 

The Wordpress::Taxonomy class provides a way to easily traverse the Wordpress taxonomy infrastructure.  It is primarily used internally and as the parent class of the Wordpress::PostTag, Wordpress::Category, and Wordpress::LinkCategory classes.  However, it can be potentially useful within your Rails project as a means of finding all posts that any particular taxonomical term is associated with.

For example:

``` ruby
taxonomy = Wordpress::Taxonomy.first # => The "General" category on my blog, a Wordpress::Category instance
taxonomy.posts.count # => 19
```

### Wordpress::User

This class provides access to the records contained in the wp_users table.  For example:

``` ruby
@author = Wordpress::User.first
@author.posts.count # => 19
```

### Wordpress::Term

The wp_terms table holds the leaf nodes of the Wordpress::Taxonomy class.  That is, the name and slug given to the specific Taxonomy.  When new tags and categories are added, the names for these are ultimately delegated to this model and the slug value computed for the new tags must be unique.  This class typically isn't directly accessed.

### Extending in your Rails projects

If you need to extend the functionality of any of the models, then this is easily done through the decorator pattern.  For example, create the following folder: ~/app/decorators/models/word_press  (This path is important to get right as the engine looks for it an auto-loads when present).

In the above folder add a decorator for the model you wish to "decorate"

Example:  ~/app/decorators/models/word_press/post_decorator.rb

``` ruby
Wordpress::Post.class_eval do
  has_many :snippets, foreign_key: "post_id"

  def has_revisions?
    !revisions.empty?
  end
  
  def tagged
    self.tags.map(&:name).join(",")
  end
end
```

### License

This project rocks and uses MIT-LICENSE.