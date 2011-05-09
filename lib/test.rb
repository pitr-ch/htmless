require 'benchmark'
require "#{File.dirname(__FILE__)}/render.rb"
#require "#{File.dirname(__FILE__)}/render_1.rb"
#require "#{File.dirname(__FILE__)}/render_2.rb"
require "#{File.dirname(__FILE__)}/render_3.rb"
require "#{File.dirname(__FILE__)}/render_4.rb"
require "#{File.dirname(__FILE__)}/hammer-builder.rb"



#r = Hammer::Builder.new
#r.go_in do
#  div do
#    div('a')[12]
#    div[13]
#  end
#end
#puts r.to_xhtml

#require 'active_support'
#require 'action_view'
#
#html = Hammer::FormatedBuilder.new.go_in do
#  extend ActionView::Helpers::NumberHelper
#  div number_with_precision(Math::PI, :precision => 4)
#end.to_xhtml
#puts html
#
#class MyBuilder < Hammer::FormatedBuilder
#  include ActionView::Helpers::NumberHelper
#end
#
#puts(MyBuilder.new.go_in do
#  div number_with_precision(Math::PI, :precision => 4)
#end.to_xhtml)


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
#end.to_xhtml
#puts html
#
#exit

class MyBuilder < HammerBuilder::Formated
  extend_class :AbstractDoubleTag do
  end
end

b = MyBuilder.get.go_in do
  puts div.rclass
  puts div.rclass.superclass
  puts div.rclass.superclass.superclass
  puts div.rclass.superclass.superclass.superclass
  puts div.rclass.superclass.superclass.superclass.superclass
  puts div.rclass.superclass.superclass.superclass.superclass.superclass
  puts div.rclass.superclass.superclass.superclass.superclass.superclass.superclass
  puts div.rclass.superclass.superclass.superclass.superclass.superclass.superclass.superclass
end.release!


b = HammerBuilder::Formated.get.go_in do
  html do
    meta.http_equiv 'asd'
    div.data_id object_id
    div object_id
    div.content object_id
    div { p 'a' }
    div[:idcko]
  end
end
puts b.to_xhtml

#exit

require 'ruby-prof'
r = HammerBuilder::Formated.new
result = RubyProf.profile do
  10.times do
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

#ENV['CPUPROFILE_OBJECTS']=1
#ENV['CPUPROFILE_FREQUENCY']='4000'

require 'perftools'

r = Hammer::Builder.new
PerfTools::CpuProfiler.start("hammer-builder") do
  1000000.times do
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
end
puts 'done'


