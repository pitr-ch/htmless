require 'simplecov'
require 'htmless'

#RSpec.configure do |config|
#  config.mock_with :rspec
#end

RSpec.describe Htmless do
  shared_examples "pool" do
    it('should return correct instance') { pool.get.should be_kind_of(Htmless::Formatted) }
    it "should return instance into pool" do
      pool.get.release
      pool.size.should == 1
      pool.get.to_html!
      pool.size.should == 1
    end
  end

  describe Htmless::Pool do
    let(:pool) { Htmless::Pool.new Htmless::Formatted }
    include_examples 'pool'
  end

  describe Htmless::SynchronizedPool do
    let(:pool) { Htmless::SynchronizedPool.new Htmless::Formatted }
    include_examples 'pool'
  end

  describe 'object with HammerBuilder::Helper' do
    let(:pool) { Htmless::Pool.new Htmless::Standard }

    class User
      extend Htmless::Helper

      builder :detail do |_, arg|
        div arg
      end

      def detail2(b, arg)
        b.div { b.text arg }
      end
    end

    describe 'User.new' do
      it { User.new.should be_respond_to(:detail) }
      it "should render correctly" do
        pool.get.dive(User.new) do |user|
          render user, :detail, 'content'
          render user, :detail2, 'content'
        end.to_html!.should == "<div>content</div><div>content</div>"
      end
    end

  end

  describe Htmless::DynamicClasses do
    class Parent
      extend Htmless::DynamicClasses
      dc do
        def_class :LeftEye do
          def to_s;
            'left eye';
          end
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
      dc do
        extend_class :LeftEye do
          def to_s;
            'laser ' + super;
          end
        end
      end
    end

    it '#to_s should print correct values' do
      Parent.dc[:LeftEye].new.to_s.should == 'left eye'
      Parent.dc[:RightEye].new.to_s.should == 'next to left eye'
      AChild.dc[:LeftEye].new.to_s.should == 'left eye'
      AChild.dc[:RightEye].new.to_s.should == 'next to left eye'
      AMutant.dc[:LeftEye].new.to_s.should == 'laser left eye'
      AMutant.dc[:RightEye].new.to_s.should == 'next to laser left eye'
    end

    it 'should create different classes for each carrying class' do
      Parent.dc[:LeftEye].should_not == AChild.dc[:LeftEye]
      Parent.dc[:LeftEye].should_not == AMutant.dc[:LeftEye]
    end

    describe 'Parent.dc.class_names' do
      it do
        Parent.dc.class_names.should include(:LeftEye, :RightEye)
        Parent.dc.class_names.size.should eq 2
      end
    end
  end

  describe Htmless::Standard do
    let(:pool) { Htmless::Pool.new Htmless::Standard }
    let(:builder) { pool.get }

    def quick_render &block
      builder.dive(&block).to_html!
    end

    it 'should render #content' do
      quick_render { div 'content' }.should == '<div>content</div>'
      quick_render { div.content 'content' }.should == '<div>content</div>'
      quick_render { div :content => 'content' }.should == '<div>content</div>'
      quick_render { div { text 'content' } }.should == '<div>content</div>'
      quick_render { div.with { text 'content' } }.should == '<div>content</div>'
    end

    it 'should render #id' do
      quick_render { div.id :an_id }.should == '<div id="an_id"></div>'
      quick_render { div id: 12 }.should == '<div id="12"></div>'
      quick_render { div 'asd', id: 12 }.should == '<div id="12">asd</div>'
      quick_render { hr.id 'an_id' }.should == '<hr id="an_id" />'
      quick_render { hr id: 'an_id' }.should == '<hr id="an_id" />'

      quick_render { hr.id 'an', 'id', nil, false }.should == '<hr id="an-id" />'
      quick_render { div.id 'an', 'id', nil, false }.should == '<div id="an-id"></div>'
    end

    it 'should render #class' do
      #noinspection RubyArgCount
      quick_render { div.class 'an_class' }.should == '<div class="an_class"></div>'
      quick_render { div :class => 'an_class' }.should == '<div class="an_class"></div>'
      #noinspection RubyArgCount
      quick_render { hr.class 'an_class' }.should == '<hr class="an_class" />'
      quick_render { hr :class => 'an_class' }.should == '<hr class="an_class" />'

      #noinspection RubyArgCount
      quick_render { div.class 'an_class', 'another_class' }.should == '<div class="an_class another_class"></div>'
      quick_render { div :class => ['an_class', 'another_class'] }.should == '<div class="an_class another_class"></div>'
      #noinspection RubyArgCount
      quick_render { div.class(false, nil, 'an_class', true && 'another_class') }.should ==
          '<div class="an_class another_class"></div>'
    end

    it 'renders method attribute on form tag' do
      quick_render { form :method => 'post' }.should == '<form method="post"></form>'
    end

    it "#attribute" do
      quick_render { div.attribute 'xml:ns', 'gibris' }.should == '<div xml:ns="gibris"></div>'
      quick_render { div.attributes 'xml:ns' => 'gibris' }.should == '<div xml:ns="gibris"></div>'
      quick_render { div.attribute(:class, 'a') { text 'asd' } }.should == '<div class="a">asd</div>'
    end

    it '#[]' do
      obj = Object.new
      quick_render { div[obj] }.should == %Q(<div id="object-#{obj.object_id}" class="object"></div>)

      class AnObject
        def self.htmless_ref
          "a"
        end

        def htmless_ref
          'b'
        end
      end
      obj = AnObject.new
      quick_render { div[obj] }.should == %Q(<div id="b" class="a"></div>)

      obj = Object.new.extend(Module.new do
                                def id;
                                  "an_id";
                                end
                              end)
      quick_render { div[obj] }.should == %Q(<div id="object-an_id" class="object"></div>)
      quick_render { div.mimic(obj) { text 'a' } }.should == %Q(<div id="object-an_id" class="object">a</div>)
    end

    it "#data-secret" do
      quick_render { div('a', data_secret: "I do not tell.") }.should == '<div data-secret="I do not tell.">a</div>'
      quick_render { div('a').data_secret("I do not tell.") }.should == '<div data-secret="I do not tell.">a</div>'
    end

    it '#data' do
      quick_render { hr.data(:secret => true) }.should == '<hr data-secret="true" />'
      quick_render { div('a', :data => {:secret => "I do not tell."}) }.should ==
          '<div data-secret="I do not tell.">a</div>'
      quick_render { div('a').data(:secret => "I do not tell.") { text 'a' } }.should ==
          '<div data-secret="I do not tell.">a</div>'
    end

    it 'tags should have all the attributes' do
      builder.tags.each do |tag|
        builder.should be_respond_to(tag)
        tag_instance = builder.send(tag)
        (Htmless::Data::HTML5.abstract_attributes.map(&:name) +
            (Htmless::Data::HTML5.single_tags + Htmless::Data::HTML5.double_tags).
                find { |t| t.name.to_s == tag }.attributes.map(&:name)).each do |attr|
          tag_instance.should be_respond_to(attr)
        end
      end
    end

    it "boolean attributes should render correctly" do
      quick_render { input.readonly }.should == '<input readonly="readonly" />'
      quick_render { option.selected { text 'asd' } }.should == '<option selected="selected">asd</option>'
      quick_render { option.selected(true) }.should == '<option selected="selected"></option>'
      quick_render { option.selected(1) }.should == '<option selected="selected"></option>'
      quick_render { option.selected(false) }.should == '<option></option>'
      quick_render { div.hidden('asd') }.should == '<div hidden="hidden"></div>'
    end

    it "should render correctly" do
      quick_render do
        html5
        html do
          head do
            title 'a_title', id: 'an-id'
            meta.charset "utf-8"
          end
          body.id 'content' do
            text 'asd'
            div.class('left').style(nil) do
              raw 'asd'
              hr
            end
            br
            div class: 'left' do
              hr
              js 'asd'
              js 'asd', :cdata => true
            end
            comment 'asd'
          end
          comment 'asd'
        end
      end.should == '<!DOCTYPE html>' + "\n" +
          '<html xmlns="http://www.w3.org/1999/xhtml"><head><title id="an-id">a_title</title><meta charset="utf-8" />'+
          '</head><body id="content">asd<div style="" class="left">asd<hr /></div><br /><div class="left"><hr />'+
          '<script type="text/javascript">asd</script><script type="text/javascript"><![CDATA[asd]]></script>'+
          '</div><!--asd--></body><!--asd--></html>'
    end

    it "#set variables" do
      r = builder.set_variables(:a => 'a') do |b|
        b.dive { p @a }
      end.to_html!

      r.should == '<p>a</p>'
      builder.instance_variable_get(:@a).should be_nil
    end

    it "#join" do
      quick_render { join([1, 2]) { |n| text n } }.should == '12'
      quick_render { join([1, 2], 'a') { |n| text n } }.should == '1a2'
      quick_render { join([lambda { text 1 }, 2], 'a') { |n| text n } }.should == '1a2'
      quick_render { join([lambda { text 1 }, 2], lambda { text 'a' }) { |n| text n } }.should == '1a2'
    end
  end

  describe Htmless::Formatted do
    let(:pool) { Htmless::Pool.new Htmless::Formatted }
    let(:builder) { pool.get }

    def quick_render &block
      builder.dive(&block).to_html!
    end

    it "should be formatted" do
      quick_render { div { comment 'asd'; br }; p }.should == "\n<div>\n  <!--asd-->\n  <br />\n</div>\n<p></p>"
    end
  end
end
