# HammerBuilder

[`HammerBuilder`](https://github.com/ruby-hammer/hammer-builder)
is a xhtml5 builder written in and for Ruby 1.9.2. It does not introduce anything special, you just
use Ruby to get your xhtml. [`HammerBuilder`](https://github.com/ruby-hammer/hammer-builder)
has been written with three objectives:

* Speed
* Rich API
* Extensibility

## Links

* Introduction:
[http://hammer.pitr.ch/2011/05/11/HammerBuilder-introduction/](http://hammer.pitr.ch/2011/05/11/HammerBuilder-introduction/)
* Yardoc: [http://hammer.pitr.ch/hammer-builder/](http://hammer.pitr.ch/hammer-builder/)
* Issues: [https://github.com/ruby-hammer/hammer-builder/issues](https://github.com/ruby-hammer/hammer-builder/issues)
* Changelog: [http://hammer.pitr.ch/hammer-builder/file.CHANGELOG.html](http://hammer.pitr.ch/hammer-builder/file.CHANGELOG.html)
* Gem: [https://rubygems.org/gems/hammer_builder](https://rubygems.org/gems/hammer_builder)

## Syntax

    HammerBuilder::Formated.get.go_in do
      xhtml5!
      html do
        head { title 'a title' }
        body do
          div.id('menu').class('left') do
            ul do
              li 'home'
              li 'contacts', :class => 'active'
            end
          end
          div.id('content') do
            article.id 'article1' do
              h1 'header'
              p('some text').class('centered')
              div(:class => 'like').class('hide').with do
                text 'like on '
                strong 'Facebook'
              end
            end
          end
        end
      end
    end.to_xhtml!

    #=>
    #<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html>
    #<html xmlns="http://www.w3.org/1999/xhtml">
    #  <head>
    #    <title>a title</title>
    #  </head>
    #  <body>
    #    <div id="menu" class="left">
    #      <ul>
    #        <li>home</li>
    #        <li class="active">contacts</li>
    #      </ul>
    #    </div>
    #    <div id="content">
    #      <article id="article1">
    #        <h1>header</h1>
    #        <p class="centered">some text</p>
    #        <div class="like hide">like on
    #          <strong>Facebook</strong>
    #        </div>
    #      </article>
    #    </div>
    #  </body>
    #</html>


## Benchmark

### Synthetic

                                  user     system      total        real
    render                    4.380000   0.000000   4.380000 (  4.394127)
    render3                   4.990000   0.000000   4.990000 (  5.017267)
    HammerBuilder::Standard   5.590000   0.000000   5.590000 (  5.929775)
    HammerBuilder::Formated   5.520000   0.000000   5.520000 (  5.511297)
    erubis                    7.340000   0.000000   7.340000 (  7.345410)
    erubis-reuse              4.670000   0.000000   4.670000 (  4.666334)
    fasterubis                7.700000   0.000000   7.700000 (  7.689792)
    fasterubis-reuse          4.650000   0.000000   4.650000 (  4.648017)
    tenjin                   11.810000   0.280000  12.090000 ( 12.084124)
    tenjin-reuse              3.170000   0.010000   3.180000 (  3.183110)
    erector                  12.100000   0.000000  12.100000 ( 12.103520)
    markaby                  20.750000   0.030000  20.780000 ( 21.371292)
    tagz                     73.200000   0.140000  73.340000 ( 73.306450)

### In Rails 3

    BenchTest#test_erubis_partials (3.34 sec warmup)
               wall_time: 3.56 sec
                  memory: 0.00 KB
                 objects: 0
                 gc_runs: 15
                 gc_time: 0.53 ms
    BenchTest#test_erubis_single (552 ms warmup)
               wall_time: 544 ms
                  memory: 0.00 KB
                 objects: 0
                 gc_runs: 4
                 gc_time: 0.12 ms
    BenchTest#test_hammer_builder (2.33 sec warmup)
               wall_time: 847 ms
                  memory: 0.00 KB
                 objects: 0
                 gc_runs: 5
                 gc_time: 0.17 ms
    BenchTest#test_tenjin_partial (942 ms warmup)
               wall_time: 1.21 sec
                  memory: 0.00 KB
                 objects: 0
                 gc_runs: 7
                 gc_time: 0.25 ms
    BenchTest#test_tenjin_single (531 ms warmup)
               wall_time: 532 ms
                  memory: 0.00 KB
                 objects: 0
                 gc_runs: 6
                 gc_time: 0.20 ms

### Conclusion

Template engines are slightly faster than [`HammerBuilder`](https://github.com/ruby-hammer/hammer-builder)
when template does not content a lot of inserting or partials.
On the other hand when partials are used, [`HammerBuilder`](https://github.com/ruby-hammer/hammer-builder)
beats template engines.
There is no overhead for partials in [`HammerBuilder`](https://github.com/ruby-hammer/hammer-builder)
compared to using partials in template engine. The difference is significant for `Erubis`, `Tenjin` is
not so bad, but I did not find any easy way to use `Tenjin` in Rails 3 (I did some hacking).
