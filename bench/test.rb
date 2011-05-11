require "#{File.dirname(__FILE__)}/../lib/hammer_builder.rb"



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

#class MyBuilder < HammerBuilder::Formated
#  extend_class :AbstractDoubleTag do
#  end
#end
#
#b = MyBuilder.get.go_in do
#  puts div.rclass
#  puts div.rclass.superclass
#  puts div.rclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass.superclass.superclass.superclass
#end.release!
class User < Struct.new(:name, :login, :email)
  include HammerBuilder::Helper

  builder :detail do |user|
    ul do
      user.attribute self, :name
      user.attribute self, :login
      user.attribute self, :email
    end
  end

  builder :attribute do |user, attribute|
    li do
      strong "#{attribute}: "
      text user.send(attribute)
    end
  end
end

puts(HammerBuilder::Formated.get.go_in do
  user = User.new("Peter", "peter", "peter@example.com")
  user.detail self
  p "builder methods are: #{User.builder_methods.join(',')}"
end.to_xhtml!)

class MyBuilder < HammerBuilder::Formated

  # define new method to all tags
  extend_class :AbstractTag do
    def hide!
      self.class 'hidden'
    end
  end

  # add pseudo tag
  define_class :Component, :Div do
    class_eval <<-RUBYCODE, __FILE__, __LINE__
      def open(id, attributes = nil, &block)
        super(attributes, &nil).id(id).class('component')
        block ? with(&block) : self
      end
    RUBYCODE
  end
  define_tag :component

  # if the class is not needed same can be done this way
  def simple_component(id, attributes = nil, &block)
    div[id].class(:component).attributes attributes, &block
  end
end

o = MyBuilder.get.go_in do
  div[:content].with do
    span[:secret].class('left').hide!
    component('component-1') do
      strong 'something'
    end
    simple_component 'component-1'
  end
end.to_xhtml!

puts o

puts(HammerBuilder::Standard.get.go_in do
  puts div.object_id
  puts div.object_id
end.to_xhtml!)

puts(HammerBuilder::Standard.get.go_in do
  a = div 'a'
  div 'b'
  a.class 'class'
end.to_xhtml!)


b = HammerBuilder::Formated.get.go_in do
  xhtml5!
  html do
    head { title }
    body do
      div.data_id object_id
      div(:id => 'a').id object_id
      div object_id
      div.content object_id
      js "var = 'asd';\n var < 12"
      div { p 'a' }
      div[:idcko]
    end
  end
end
puts b.to_xhtml

exit

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
PerfTools::CpuProfiler.start("hammer_builder") do
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


