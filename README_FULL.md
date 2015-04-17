# Htmless

**Fast** and **extensible** HTML5 builder in pure **Ruby**

-   Documentation: <http://blog.pitr.ch/htmless>
-   Source: <https://github.com/pitr-ch/htmless>
-   Blog: <http://blog.pitr.ch/blog/categories/htmless/>

## Quick syntax example

```ruby
Htmless::Formatted.new.go_in do
  html5
  html do
    head { title 'my_page' }
    body do
      div id: :content do
        p.centered "my page's content"
      end
    end
  end
end.to_html
```

returns

```html5
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>my_page</title>
  </head>
  <body>
    <div id="content">
      <p class="centered">my page's content</p>
    </div>
  </body>
</html>
```

## Why?

I needed html builder with these characteristics:

*   Ruby
*   Fast
*   Extensibility for each tag

Disadvanteges of other options:

*   Erector - quite high level, no tag extensibility
*   Markaby - slow
*   Wee::Brush - extensible but not a standalone gem
*   Tagz - very slow
*   Erubis - fast but template engine and no tag extensibility
*   Tenjin - faster but template engine and no tag extensibility

## Chaining

    !!!ruby
    div.class('left').id('menu').class('border').onclick('run();').with do
      text 'hello'
    end

prints

    !!!html
    <div class="left border" id="menu" onclick="run();">hello</div>

Content block must be last in the chain. No other calls are allowed after block.

    !!!ruby
    div do
      text 'content'
    end.id('an_id') # won't work

## Attributes

    !!!ruby
    div :id => 'menu', :class => 'left' # is shortcut for:
    div.attributes :id => 'menu', :class => 'left'

*   `#attributes` calls underlining methods `#id` and `#class`
*   If you extend tag by a method, you can call it through `#attributes` or `#attribute`

Any attribute method you call is immediately appended to output with exception of classes. They are acumulating
until tag is closed.

    !!!ruby
    div(:class => 'left').class('center') # <div class='left center'></div>
    div(:id => 1).id(2)                   # <div id="1" id="2"></div>

Undefined attribute can be rendered with `#atttribute` or `#attributes` methods.

    !!!ruby
    html.attribute :xmlns, 'http://www.w3.org/1999/xhtml'
    # => <html xmlns="http://www.w3.org/1999/xhtml"></html>
    html.attributes xmlns: 'http://www.w3.org/1999/xhtml'
    # => <html xmlns="http://www.w3.org/1999/xhtml"></html>
    html xmlns: 'http://www.w3.org/1999/xhtml'
    # => <html xmlns="http://www.w3.org/1999/xhtml"></html>

If `#attribute` finds defined method for desired attribute, the method is called.

    !!!ruby
    div.attribute :class => 'left' # is equvivalent to:
    div.class 'left'

## Content, Boolean attributes

    !!!ruby
    div 'content'                       # <div>content</div>
    div.content 'content'               # <div>content</div>
    div :content => 'content'           # <div>content</div>
    div { text 'content' }              # <div>content</div>
    div.with { text 'content' }         # <div>content</div>
    div 'content', :id => :id           # <div id="id">content</div>
    div(:id => :id) { text 'content' }  # <div id="id">content</div>
    div.id :id do
      text 'content'
    end                                 # <div id="id">content</div>

### Boolean attributes

Attributes like `checked` and `disabled` test value for true, if false they render nothing

    !!!ruby
    input.disabled am_i_disabled?
    # => <input disabled="disabled" />
    # or <input />

## Id, class and mimic

`#class` accepts an array, values are joined with spaces and `false`, `nil` values are ignored

    !!!ruby
    div.class('menu', 'big', hide? && 'hidden')
    # => <div class="menu big hidden"></div>
    # or <div class="menu big"></div>

`#id` accepts also an array, values are joined with '-' and `false`, `nil` values are ignored

    !!!ruby
    div.id('menu', 'big', a_failing_test && 'useless') # => <div id="menu-big"></div>

Object (model) can be used to set class and id

    !!!ruby
    user = User.new(:id => 1)
    div(:class => 'model')[user].with { text 'data' }
    # => <div id="user-1" class="model user">data</div>

`#mimic` which is aliased as `#[]` looks for `.htmless_ref` or it uses the class name to render the class part.
As id is used already determined class and `#htmless_ref`, `#id`, `#object_id` which one is found first.

## Data attributes, Join

### Data attributes

    !!!ruby
    div.data_secret("I won't tell.") # => <div data-secret="I won't tell."></div>
    data :secret => "I won't tell."  # => <div data-secret="I won't tell."></div>


### Join

`#join` enables easy rendering of collections

    !!!ruby
    join([1, 1.2], ->{ text ', ' }) {|n| b "#{n}cm" }
        # => "<b>1cm</b>, <b>1.2cm</b>"
    join([1, 1.2], ', ') {|n| b "#{n}cm" }
        # => "<b>1cm</b>, <b>1.2cm</b>"
    join([1, ->{ text 'missing' }], ', ') {|n| b "#{n}cm" }
        # => "<b>1cm</b>, missing"

A block in the collection is rendered directly without iterator. This can be useful when menu with some delimiters
is rendered based on collection of some objects and you need to add one or more untypical menu items.

## '_' vs '-'

'_' in attributes is transformed to '-'

    !!!ruby
    meta.http_equiv 'Content-Type' # => <meta http-equip="Content-Type" />

Ids generated by Arrays are joined with '-'

    !!!ruby
    div.id('an', 'id') # => <div id="an-id"></div>


## Tag's representation

Each tag has its own class.

    !!!ruby
    div.rclass # => #<Class:0x00000001d449b8(Htmless::Formatted.dc[:Div])>
    li.rclass  # => #<Class:0x00000001d449b8(Htmless::Formatted.dc[:Li])>

`#rclass` is original ruby method `#class`


## Getting a builder

Creating new builder is relatively expensive. There is a pool of builders implemented.

    !!!ruby
    if am_i_smart?
      pool = Htmless::Pool.new Htmless::Formatted # store pool somewhere globalish for reuse
      builder = pool.get # => new builder from pool if there is one, or a newlly created one
      # ... do yours stuff
      builder.release # resets builder and returns it to the pool
    else
      b = Htmless::Formatted.new
      # ... do yours stuff
      # later on builder gets garbage collected
    end

Be careful not to use builder after you have released it.

    !!!ruby
    if am_i_freaking_smart?
      pool = Htmless::Pool.new Htmless::Formatted
      xhtml = pool.get.go_in(your_data) do |data|
        # render your data ...
      end.to_html! # returns xhtml and releases the builder
    end

This way builder doesn't get stored anywhere.

## How to use

The idea is that any object intended to rendering will have methods which renders the object into builder.
There is a `Htmless::Helper` and method `#render` (also aliased as `#r`) for that purpose.

    !!!ruby
    class User < Struct.new(:name, :login, :email)
      extend Htmless::Helper

      builder :detail do |user|
        ul do
          r user, :attribute, :name
          r user, :attribute, :login
          r user, :attribute, :email
        end
      end

      def attribute(b, attribute)
        b.li do
          b.strong "#{attribute}: "
          b.text self.send(attribute)
        end
      end
    end

`.builder` is just shortcut to define method `User#detail` like this:

    !!!ruby
    def detail(b)
      b.go_in(self) do |user| # this block is the same as the one passed
        ul do                 # above to .builder
          r user, :attribute, :name
          r user, :attribute, :login
          r user, :attribute, :email
        end
      end
    end

is same as

    !!!ruby
    builder :detail do |user|
      ul do
        r user, :attribute, :name
        r user, :attribute, :login
        r user, :attribute, :email
      end
    end

and

    !!!ruby
    user = User.new("Peter", "peter", "peter@example.com")
    pool.get.dive do
      r user, :detail
    end.to_html!

returns:

    !!!html
    <ul>
      <li>
        <strong>name: </strong>Peter
      </li>
      <li>
        <strong>login: </strong>peter
      </li>
      <li>
        <strong>email: </strong>peter@example.com
      </li>
    </ul>

## Contexts

Html can be rendered outside of builder's context

    !!!ruby
    class User
      attr_reder :name, :age
      def detail(b) # builder
        b.ul { b.li name; b.li name }
      end
    end

or `#go_in` (also aliased as `#dive`) can be used to get into builder's context

    !!!ruby
    class User
      extend Htmless::Helper
      attr_reder :name, :age
      builder :detail do |user|
        ul { li user.name; li user.age }
      end
    end
    # => <ul><li>john Doe</li><li>25</li></ul>

## Helpers

If they are needed they can be mixed directly into Builder's instance

    !!!ruby
    Htmless::Formatted.new.go_in do
      extend ActionView::Helpers::NumberHelper
      div number_with_precision(Math::PI, :precision => 4)
    end.to_html # => <div>3.1416</div>

*Be careful when you are using this with `Pool`. Some instances may have helpers and some don't.*

Or new builder descendant can be made.

    !!!ruby
    class MyBuilder < Hammer::FormattedBuilder
      include ActionView::Helpers::NumberHelper
    end

    MyBuilder.new.go_in do
      div number_with_precision(Math::PI, :precision => 4)
    end.to_html # => <div>3.1416</div>

## Implementation details - Tag's shared instances

There are no multiple instances for each tag.
Every tag of the same type share a same instance (unique within the instance of a builder).

    !!!ruby
    puts(pool.get.go_in do
      puts div.object_id
      puts div.object_id
    end.to_html!)
    # =>
    # 10069200
    # 10069200
    # <div></div><div></div>

`Htmless` creates what he can prior to rendering and uses heavily meta-programming, because of that instantiating
the very first instance of builder triggers some magic staff taking about a one second. Creating new builders of the
same class is than much faster and getting builder from a pool is instant.

This won't work:

    !!!ruby
    puts(pool.get.go_in do
      a = div 'a'
      div 'b'
      a.class 'class'
    end.to_html!)
    # => <div>a</div><div class="class">b</div>

because when `#class` is called the second div is being built.

## Implementation details - DynamicClasses

    !!!ruby
    class Parent
      class LeftEye
        def to_s
          'left eye'
        end
      end
      class RightEye < LeftEye
        def to_s
          'next to ' + super
        end
      end
    end
    class AChild < Parent
    end
    class AMutant
      class LeftEye < superclass::LeftEye
        def to_s
          'laser ' + super
        end
      end
    end

How to define `AMutant::RihtEye` to return `"next to laser left eye"` ?

    !!!ruby
    class Parent
      extend DynamicClasses
      dynamic_classes do
        def_class :LeftEye do
          def to_s; 'left eye'; end
        end
        def_class :RightEye, :LeftEye do
          class_eval <<-RUBYCODE, __FILE__, __LINE__+1
            def to_s; 'next to ' + super; end
          RUBYCODE
        end
      end
    end

    class AChild < Parent
    end

    class AMutant < Parent
      dynamic_classes do
        extend_class :LeftEye do
          def to_s; 'laser ' + super; end
        end
      end
    end

Each class is a different object.

    !!!ruby
    Parent.dynamic_classes[:LeftEye] # => #<Class:0x00000001d449b8(A.dc[:LeftEye])>
    AChild.dynamic_classes[:LeftEye] # => #<Class:0x00000001d42398(A.dc[:LeftEye])>

`AMutant.dc[:RightEye]` automatically inherits from extended `AMutant.dc[:LeftEye]`

    !!!ruby
    Parent.dc[:LeftEye].new.to_s   # => 'left eye'
    Parent.dc[:RightEye].new.to_s  # => 'next to left eye'

    AChild.dc[:LeftEye].new.to_s   # => 'left eye'
    AChild.dc[:RightEye].new.to_s  # => 'next to left eye'

    AMutant.dc[:LeftEye].new.to_s  # => 'laser left eye'
    AMutant.dc[:RightEye].new.to_s # => 'next to laser left eye'

## Extensibility

    !!!ruby
    class MyBuilder < Htmless::Formatted
      dynamic_classes do
        # define new method to all tags
        extend_class :AbstractTag do
          def hide!
            self.class 'hidden'
          end
        end

        # add pseudo tag
        def_class :Component, :Div do
          class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
            def open(id, attributes = nil, &block)
              super(attributes, &nil).id(id).class('component')
              block ? with(&block) : self
            end
          RUBYCODE
        end
      end

      define_tag :component

      # if the class is not needed same can be done this way
      def simple_component(id, attributes = {}, &block)
        div.id(id).attributes attributes, &block
      end
    end

    MyBuilder.new.go_in do
      div.content!.with do
        span.secret!.class('left').hide!
        component('component-1') do
          strong 'something'
        end
        simple_component 'component-1'
      end
    end.to_html

returns

    !!!html
    <div id="content">
      <span id="secret" class="left hidden"></span>
      <div id="component-1" class="component">
        <strong>something</strong>
      </div>
      <div id="component-1"></div>
    </div>

## Benchmarks

### Synthetic

Benchmark can be found on Github. It renders simple page with two collections. 'reuse' means
that template is precompiled and reused during benchmark.

                                   user     system      total        real
    tenjin-reuse               2.040000   0.000000   2.040000 (  2.055140)
    Htmless::Standard          2.520000   0.000000   2.520000 (  2.519284)
    fasterubis-reuse           2.580000   0.000000   2.580000 (  2.581407)
    erubis-reuse               2.680000   0.000000   2.680000 (  2.690176)
    Htmless::Formatted         2.780000   0.000000   2.780000 (  2.794307)
    erubis                     5.180000   0.000000   5.180000 (  5.183333)
    fasterubis                 5.210000   0.000000   5.210000 (  5.219176)
    tenjin                     7.650000   0.160000   7.810000 (  7.820490)
    erector                    9.450000   0.010000   9.460000 (  9.471654)
    markaby                   14.300000   0.000000  14.300000 ( 14.318844)
    tagz                      33.430000   0.000000  33.430000 ( 33.483693)

### Rails 3

Benchmark can be found on Github.
Single page with or without a partial which is rendered 200 times. Partials make no difference for Htmless.

    BenchTest#test_erubis_partials (3.34 sec warmup)
               wall_time: 3.56 sec
                 gc_runs: 15
                 gc_time: 0.53 ms
    BenchTest#test_erubis_single (552 ms warmup)
               wall_time: 544 ms
                 gc_runs: 4
                 gc_time: 0.12 ms
    BenchTest#test_htmless (2.33 sec warmup)
               wall_time: 847 ms
                 gc_runs: 5
                 gc_time: 0.17 ms
    BenchTest#test_tenjin_partial (942 ms warmup)
               wall_time: 1.21 sec
                 gc_runs: 7
                 gc_time: 0.25 ms
    BenchTest#test_tenjin_single (531 ms warmup)
               wall_time: 532 ms
                 gc_runs: 6
                 gc_time: 0.20 ms

## Why is it fast?

*   Optimization of garbage collecting.
    *   10-15% improvement.
    *   Pre-initialization (tag's instances, even strings).
    *   No string's `#+`, `#{}`. Just `#<<` to buffer.
    *   Precomputed spaces for indentation.
*   Doing as less as possible when rendering.
*   Magic by meta-programing not by `method_missing`. Magic is run on initialization not when rendering.
*   Number of micro optimization.
    *   Data in constants or instance variables.
    *   Buffer.
    *   No `#define_method`.
    *   Method inlining.
    *   Probably no real effect :)

## Future plans

*   compile rendering methods on objects to javascript which will render html form json
*   Helpers for Sinatra, Rails 3
*   Helpers for fragment caching

## Why use it?

*   Its as fast as template-engines (erb) and much faster then other Ruby HTML builders.
*   You can use inheritance (impossible with templates) and other goodness of Ruby.
*   You can write html in pure Ruby.
