require 'benchmark'
require "#{File.dirname(__FILE__)}/render.rb"
#require "#{File.dirname(__FILE__)}/render_1.rb"
#require "#{File.dirname(__FILE__)}/render_2.rb"
require "#{File.dirname(__FILE__)}/render_3.rb"
require "#{File.dirname(__FILE__)}/render_4.rb"
require "#{File.dirname(__FILE__)}/hammer-builder.rb"

class ::Class
  def spy
    klass = self
    Class.new(self) do
      public_instance_methods.each do |name|
        define_method(name) do |*args, &block|
          puts "#{name} called on #{klass} with #{args.inspect}"
          ret = super(*args, &block)
          puts "out: #{@output.inspect}", "stack: #{@stack.inspect}"
          ret
        end
      end
    end
  end
end

#TIMES = 100000
#TIMES =  75000
TIMES =  50000
#TIMES =   5000
#TIMES =   1000
#TIMES =    500
#TIMES =    100
#TIMES =      1



#r = Hammer::Builder.new
#r.go_in do
#  div do
#    div('a')[12]
#    div[13]
#  end
#end
#puts r.to_html

#require 'active_support'
#require 'action_view'
#
#html = Hammer::FormatedBuilder.new.go_in do
#  extend ActionView::Helpers::NumberHelper
#  div number_with_precision(Math::PI, :precision => 4)
#end.to_html
#puts html
#
#class MyBuilder < Hammer::FormatedBuilder
#  include ActionView::Helpers::NumberHelper
#end
#
#puts(MyBuilder.new.go_in do
#  div number_with_precision(Math::PI, :precision => 4)
#end.to_html)


#class MyBuilder < Hammer::FormatedBuilder
#  redefine_class :abstract_tag do
#    def hide!
#      self.class 'hidden'
#    end
#  end
#
#  define_tag_class :component, :div do
#    class_eval <<-RUBYCODE, __FILE__, __LINE__
#      def open(id, attributes = nil, &block)
#        super(attributes, &nil).id(id).class('component')
#        block ? with(&block) : self
#      end
#RUBYCODE
#  end
#end
#
#html = MyBuilder.new.go_in do
#  div[:content].with do
#    span.id('secret').class('left').hide!
#    component('component-1') do
#      strong 'something'
#    end
#  end
#end.to_html
#puts html
#
#exit


#html = Hammer::FormatedBuilder.new.go_in do
#  xhtml5!
#  html do
#    head { title 'a title' }
#    body do
#      div.id('menu').class('left') do
#        ul do
#          li 'home'
#          li 'contacts', :class => 'active'
#        end
#      end
#      div.id('content') do
#        article.id 'article1' do
#          h1 'header'
#          p('some text').class('centered')
#          div(:class => 'like').class('hide').with do
#            a.href('http://www.facebook.com/') do
#              text 'like on '
#              strong 'Facebook'
#            end
#          end
#        end
#      end
#    end
#  end
#end.to_html
#puts html
#
#exit


require 'ruby-prof'

r = Hammer::Builder.new
result = RubyProf.profile do  
  4000.times do
    r.go_in do
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
                a.href('http://www.facebook.com/') do
                  text 'like on '
                  strong 'Facebook'
                end
              end
            end
          end
        end
      end
    end
    r.reset
  end
  puts 'done'
end

printer = RubyProf::GraphHtmlPrinter.new(result)
File.open('report.html', 'w') { |report| printer.print(report, :min_percent=>0) }

exit


class AModel
  attr_reader :a, :b
  def initialize(a,b)
    @a, @b = a, b
  end
end

require 'markaby'
require 'erubis'
require 'tagz'
require 'erector'

Benchmark.bmbm(23) do |b|
  b.report("render") do
    model = AModel.new 'a', 'b'    
    TIMES.times do
      r = Render::Builder.new
      r.html.with do
        r.head
        r.body.with do
          r.div.id('menu').with do
            r.ul.with do
              10.times do
                r.li model.a
                r.li model.b
              end
            end
          end
          r.div.id('content').with do
            10.times { r.text 'asd asha sdha sdjhas ahs'*10 }
          end
        end
      end
      puts r.to_s if TIMES == 1
    end
  end
  b.report("render3") do
    model = AModel.new 'a', 'b'
    TIMES.times do
      r = Render3::Builder.new
      r.go_in do 
        html do
          head
          body do
            div :id => 'menu' do
              ul do
                10.times do
                  li model.a
                  li model.b
                end
              end
            end
            div['content'].with do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      puts r.to_s if TIMES == 1
    end
  end
  b.report("hammer-builder") do
    model = AModel.new 'a', 'b'
    r = Hammer::Builder.new
    TIMES.times do      
      r.go_in do
        html do
          head
          body do
            div :id => 'menu' do
              ul do
                10.times do
                  li model.a
                  li model.b
                end
              end
            end
            div['content'].with do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      puts r.to_s if TIMES == 1
      r.reset
    end
  end
  b.report("hammer-formated_builder") do
    model = AModel.new 'a', 'b'
    r = Hammer::FormatedBuilder.new
    TIMES.times do
      r.go_in do
        html do
          head
          body do
            div :id => 'menu' do
              ul do
                10.times do
                  li model.a
                  li model.b
                end
              end
            end
            div['content'].with do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      puts r.to_s if TIMES == 1
      r.reset
    end
  end

  TEMPLATE = <<TMP
<html>
<head></head>
<body><div id="menu"><ul>
<% 10.times do %>
<li><%= model.a %></li><li><%= model.b %></li>
<% end %>
</ul></div>
<div id="content">
<% 10.times do %>
<%= 'asd asha sdha sdjhas ahs'*10 %>
<% end %>
</div></body></html>
TMP

  b.report('erubis') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      Erubis::Eruby.new(TEMPLATE).result(binding())
    end
    GC.start
  end
  b.report('erubis-cache') do
    model = AModel.new 'a', 'b'
    erub = Erubis::Eruby.new(TEMPLATE)
    TIMES.times do
      erub.result(binding())
    end
    GC.start
  end
  b.report('fasterubis') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      Erubis::FastEruby.new(TEMPLATE).result(binding())
    end
    GC.start
  end

  b.report('fasterubis-cache') do
    model = AModel.new 'a', 'b'
    erub = Erubis::FastEruby.new(TEMPLATE)
    TIMES.times do
      erub.result(binding())
    end
    GC.start
  end

  class AWidget < Erector::Widget
    def content
      html do
        head {}
        body do
          div :id => 'menu' do
            ul do
              10.times do
                li @model.a
                li @model.b
              end
            end
          end
          div :id => 'content' do
            10.times { text 'asd asha sdha sdjhas ahs'*10 }
          end
        end
      end
    end
  end

  b.report('erector') do
    model = AModel.new 'a', 'b'
    w = AWidget.new :model => model
    TIMES.times do      
      w.to_html
      puts w.to_html if TIMES == 1
    end
  end

  b.report('markaby') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      r = Markaby::Builder.new(:model => model) do
        html do
          head {}
          body do
            div :id => 'menu' do
              ul do
                10.times do
                  li model.a
                  li model.b
                end
              end
            end
            div :id => 'content' do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      puts r.to_s if TIMES == 1
    end
  end

  include Tagz

  b.report('tagz') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      r = html_ do
        head_
        body_ do
          div_ :id => 'menu' do
            ul_ do
              10.times do
                li_ model.a
                li_ model.b
              end
            end
          end
          div_ :id => 'content' do
            10.times { text_ 'asd asha sdha sdjhas ahs'*10 }
          end
        end
      end
      puts r.to_s if TIMES == 1
    end
  end
end


