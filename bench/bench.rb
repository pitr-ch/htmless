require 'benchmark'
#require "#{File.dirname(__FILE__)}/render.rb"
#require "#{File.dirname(__FILE__)}/render_1.rb"
#require "#{File.dirname(__FILE__)}/render_2.rb"
#require "#{File.dirname(__FILE__)}/render_3.rb"
#require "#{File.dirname(__FILE__)}/render_4.rb"

$: << "#{File.dirname(__FILE__)}/../lib"
require "hammer_builder.rb"

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

#TIMES    = 50000
TIMES    = 25000
#TIMES    = 10000
#TIMES    = 2500
#TIMES    = 1000
#TIMES    = 500
#TIMES    = 100
#TIMES    = 1
BERECTOR = false
BTENJIN  = false
BMARKABY = false
BTAGZ    = false


class AModel
  attr_reader :a, :b

  def initialize(a, b)
    @a, @b = a, b
  end
end

Benchmark.bmbm(23) do |b|
  model = AModel.new 'a', 'b'
  b.report("HammerBuilder::Standard") do
    pool    = HammerBuilder::Pool.new HammerBuilder::Standard
    builder = pool.get
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
            div.content! do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      puts builder.to_xhtml if TIMES == 1
      builder.reset
    end
    builder.release
  end
  b.report("HammerBuilder::Formatted") do
    pool    = HammerBuilder::Pool.new HammerBuilder::Formatted
    builder = pool.get
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
            div.content! do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      puts builder.to_xhtml if TIMES == 1
      builder.reset
    end
    builder.release
  end

  require 'erubis'

  ERB_TEMPLATE = <<TMP
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
      Erubis::Eruby.new(ERB_TEMPLATE).result(binding())
    end
  end
  b.report('erubis-reuse') do
    erub = Erubis::Eruby.new(ERB_TEMPLATE)
    TIMES.times do
      erub.result(binding())
    end
  end
  b.report('fasterubis') do
    TIMES.times do
      Erubis::FastEruby.new(ERB_TEMPLATE).result(binding())
    end
  end
  b.report('fasterubis-reuse') do
    erub = Erubis::FastEruby.new(ERB_TEMPLATE)
    TIMES.times do
      erub.result(binding())
    end
  end

  if BTENJIN
    require 'tenjin'

    b.report('tenjin') do
      tnj = nil
      TIMES.times do
        tnj = Tenjin::Template.new "#{File.dirname(__FILE__)}/tenjin.rbhtml"
        tnj.render(:model => model)
      end
      puts tnj.render(:model => model) if TIMES == 1
    end

    b.report('tenjin-reuse') do
      tnj = Tenjin::Template.new "#{File.dirname(__FILE__)}/tenjin.rbhtml"
      TIMES.times do
        tnj.render(:model => model)
      end
      puts tnj.render(:model => model) if TIMES == 1
    end

  end

  if BERECTOR

    require 'erector'
    class AWidget < Erector::Widget
      def content
        html do
          head { }
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

  end
  if BMARKABY
    require 'builder'
    module Markaby
      class Fragment < ::Builder::BlankSlate
        def to_s
        end

        def inspect
        end
      end
    end
    require 'markaby'

    b.report('markaby') do
      TIMES.times do
        mark = Markaby::Builder.new(:model => model) do
          html do
            head { }
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
  end
  if BTAGZ

    require 'tagz'
    class ATagz
      include Tagz
    end
    b.report('tagz') do
      ATagz.new.instance_eval do
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
  end
end


#                               user     system      total        real
#HammerBuilder::Standard    4.560000   0.020000   4.580000 (  4.812072)
#HammerBuilder::Formatted   4.790000   0.000000   4.790000 (  4.796346)
#erubis                     6.150000   0.000000   6.150000 (  6.252211)
#erubis-reuse               3.740000   0.000000   3.740000 (  3.738390)
#fasterubis                 6.430000   0.000000   6.430000 (  6.431873)
#fasterubis-reuse           3.750000   0.010000   3.760000 (  3.768830)
