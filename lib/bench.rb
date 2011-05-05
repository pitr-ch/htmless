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

#TIMES =  50000
TIMES =  25000
#TIMES =  10000
#TIMES =   5000
#TIMES =   1000
#TIMES =    500
#TIMES =    100
#TIMES =      2


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
  model = AModel.new 'a', 'b'
  b.report("render") do        
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
  builder = Hammer::Builder.new
  b.report("hammer-builder") do
    TIMES.times do      
      builder.go_in do
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
      puts builder.to_html if TIMES == 1
      builder.reset
    end
  end
  builder = Hammer::FormatedBuilder.new
  b.report("hammer-formated_builder") do
    TIMES.times do
      builder.go_in do
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
      puts builder.to_html if TIMES == 1
      builder.reset
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
    TIMES.times do
      Erubis::Eruby.new(TEMPLATE).result(binding())
    end
    GC.start
  end
  erub = Erubis::Eruby.new(TEMPLATE)
  b.report('erubis-cache') do
    TIMES.times do
      erub.result(binding())
    end
    GC.start
  end
  b.report('fasterubis') do
    TIMES.times do
      Erubis::FastEruby.new(TEMPLATE).result(binding())
    end
    GC.start
  end
  erub = Erubis::FastEruby.new(TEMPLATE)
  b.report('fasterubis-cache') do
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

  w = AWidget.new :model => model
  b.report('erector') do
    TIMES.times do
      w.to_html
      puts w.to_html if TIMES == 1
    end
  end

  
  b.report('markaby') do
    TIMES.times do
      mark = Markaby::Builder.new(:model => model) do
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
    end
    puts mark.to_s if TIMES == 1
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


