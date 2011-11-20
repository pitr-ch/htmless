# HammerBuilder

Fast Ruby xhtml5 renderer

## Links

*   **Presentation**: <http://hammer.pitr.ch/hammer_builder/presentation/presentation.html>
*   Gemcutter: <https://rubygems.org/gems/hammer_builder>
*   Github: <https://github.com/ruby-hammer/hammer-builder>
*   Yardoc: <http://rubydoc.info/github/ruby-hammer/hammer-builder/frames>
*   Issues: <https://github.com/ruby-hammer/hammer-builder/issues>
*   Changelog: <http://hammer.pitr.ch/hammer-builder/file.CHANGELOG.html>
*   Gem: [https://rubygems.org/gems/hammer_builder](https://rubygems.org/gems/hammer_builder)
*   Blog: <http://hammer.pitr.ch/>

## Syntax

    HammerBuilder::Formated.new.go_in do
      xhtml5!
      html do
        head { title 'a title' }
        body do
          div.menu!.left do
            ul do
              li 'home'
              li 'contacts', :class => 'active'
            end
          end
          div.content! do
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
    tenjin-reuse               2.040000   0.000000   2.040000 (  2.055140)
    HammerBuilder::Standard    2.520000   0.000000   2.520000 (  2.519284)
    fasterubis-reuse           2.580000   0.000000   2.580000 (  2.581407)
    erubis-reuse               2.680000   0.000000   2.680000 (  2.690176)
    HammerBuilder::Formatted   2.780000   0.000000   2.780000 (  2.794307)
    erubis                     5.180000   0.000000   5.180000 (  5.183333)
    fasterubis                 5.210000   0.000000   5.210000 (  5.219176)
    tenjin                     7.650000   0.160000   7.810000 (  7.820490)
    erector                    9.450000   0.010000   9.460000 (  9.471654)
    markaby                   14.300000   0.000000  14.300000 ( 14.318844)
    tagz                      33.430000   0.000000  33.430000 ( 33.483693)

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
