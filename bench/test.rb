$: << "#{File.dirname(__FILE__)}/../lib"

require "hammer_builder.rb"
pool = Htmless::Pool.new Htmless::Formatted

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


#class MyBuilder1 < HammerBuilder::Formatted
#  dynamic_classes do
#    extend :AbstractDoubleTag do
#    end
#  end
#end
#HammerBuilder::Pool.new MyBuilder1
#b = MyBuilder1.get.go_in do
#  puts div.rclass
#  puts div.rclass.attributes.inspect
#  puts meta.rclass.attributes.inspect
#  puts div.rclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass.superclass.superclass
#  puts div.rclass.superclass.superclass.superclass.superclass.superclass.superclass.superclass
#
#end.release
#
#

class User < Struct.new(:name, :login, :email)
  include Htmless::Helper

  builder :detail do |user|
    ul do
      render user, :attribute, :name
      render user, :attribute, :login
      render user, :attribute, :email
    end
  end

  builder :attribute do |user, attribute|
    li do
      strong "#{attribute}: "
      text user.send(attribute)
    end
  end
end

puts(pool.get.go_in do
  user = User.new("Peter", "peter", "peter@example.com")
  render user, :detail
  p "builder methods are: #{User.builder_methods.join(',')}"
end.to_html!)

#exit

#class MyBuilder < HammerBuilder::Formatted
#  dynamic_classes do
#    # define new method to all tags
#    extend :AbstractTag do
#      def hide!
#        self.class 'hidden'
#      end
#    end
#
#    # add pseudo tag
#    define :Component, :Div do
#      class_eval <<-RUBYCODE, __FILE__, __LINE__
#      def open(id, attributes = nil, &block)
#        super(attributes, &nil).id(id).class('component')
#        block ? with(&block) : self
#      end
#RUBYCODE
#    end
#    base.define_tag :component
#  end
#
#  # if the class is not needed same can be done this way
#  def simple_component(id, attributes = nil, &block)
#    div[id].class(:component).attributes attributes, &block
#  end
#end

#o = MyBuilder.get.go_in do
#  div[:content].with do
#    span[:secret].class('left').hide!
#    component('component-1') do
#      strong 'something'
#    end
#    simple_component 'component-1'
#  end
#end.to_html!
#
#puts o

#puts(HammerBuilder::Standard.get.go_in do
#    puts div.object_id
#    puts div.object_id
#  end.to_html!)
#
#puts(HammerBuilder::Standard.get.go_in do
#    a = div 'a'
#    div 'b'
#    a.class 'class'
#  end.to_html!)

#class User
#  include HammerBuilder::Helper
#
#  builder :menu do
#    div @user.object_id
#  end
#end
#
#b = pool.get
#b.set_variables(:user => User.new) do
#  b.go_in do
#    @user.menu self
#  end
#end
#puts b.to_html!

b = pool.get.go_in do
  xhtml5!
  html do
    head do
      title.idcko!
      meta.name('asd').content('asd')
      meta name: 'asd', content: nil
    end
    body do
#      div.data_id object_id
#      div(:id => 'a').id object_id
#      div object_id
#      div.content object_id
#      js "var = 'asd';\n var < 12"
#      div { p 'a' }
#      div[:idcko]
#      puts Object
#      puts Object.inspect
#      puts Object.new
#      puts Object.new.inspect
#      puts current
#      puts current.inspect

      join([1, 1.2], lambda { text ', ' }) { |o| text o } # => "1, 1.2"
      join([1, 1.2], ', ') { |o| text o }                 # => "1, 1.2"
      join([->{ text 1 }, 1.2], ', ') { |o| text o }      # => "1, 1.2"

      div.menu!.left "asd"
      div.menu! 'asd'
      div.menu!.content "assd"

      hr.id(:asd)
      hr.idcko! #FIXME


      js 'a_js_function();'
    end
  end
end
puts b.to_html

exit

require 'ruby-prof'

result = RubyProf.profile do
  10000.times do
    r = Htmless::Formatted.get!
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
    r.to_html!
  end
  puts 'done'
end

printer = RubyProf::GraphHtmlPrinter.new(result)
File.open("#{File.dirname(__FILE__)}/report.html", 'w') { |report| printer.print(report, :min_percent=>0) }
printer = RubyProf::FlatPrinter.new(result)
File.open("#{File.dirname(__FILE__)}/report.txt", 'w') { |report| printer.print(report, :min_percent=>0) }


#ENV['CPUPROFILE_OBJECTS']=1
#ENV['CPUPROFILE_FREQUENCY']='4000'

exit

require 'perftools'

r = Htmless::Formatted.new
PerfTools::CpuProfiler.start("hammer_builder") do
  100000.times do
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


