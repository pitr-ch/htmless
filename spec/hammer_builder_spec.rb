require 'spec_helper'

describe HammerBuilder do
  shared_examples "pool" do
    it('should return correct instance') { pool.get.should be_kind_of(HammerBuilder::Formatted) }
    it "should return instance into pool" do
      pool.get.release
      pool.size.should == 1
      pool.get.to_xhtml!
      pool.size.should == 1
    end
  end

  describe HammerBuilder::Pool do
    let(:pool) { HammerBuilder::Pool.new HammerBuilder::Formatted }
    include_examples 'pool'
  end

  describe HammerBuilder::SynchronizedPool do
    let(:pool) { HammerBuilder::SynchronizedPool.new HammerBuilder::Formatted }
    include_examples 'pool'
  end

  describe 'object with HammerBuilder::Helper' do
    let(:pool) { HammerBuilder::Pool.new HammerBuilder::Standard }

    class User
      include HammerBuilder::Helper

      builder :detail do |_, arg|
        div arg
      end
    end

    describe 'User.new' do
      it { User.new.should be_respond_to(:detail) }
      it "should render correctly" do
        pool.get.dive(User.new) do |user|
          render user, :detail, 'content'
        end.to_xhtml!.should == "<div>content</div>"
      end
    end

    describe '.builder_methods' do
      it { User.builder_methods.should include(:detail) }
    end
  end

  describe HammerBuilder::DynamicClasses do
    class Parent
      extend HammerBuilder::DynamicClasses
      dc do
        define :LeftEye do
          def to_s;
            'left eye';
          end
        end

        define :RightEye, :LeftEye do
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
        extend :LeftEye do
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
        Parent.dc.class_names.should have(2).items
      end
    end
  end

  describe HammerBuilder::Standard do
    let(:pool) { HammerBuilder::Pool.new HammerBuilder::Standard }
    let(:builder) { pool.get }

    def quick_render &block
      builder.dive(&block).to_xhtml!
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
      quick_render { div.an_id! }.should == '<div id="an_id"></div>'
      quick_render { div.an_id! { text 'content' } }.should == '<div id="an_id">content</div>'
      quick_render { div.an_id! 'content' }.should == '<div id="an_id">content</div>'
      quick_render { div.an_id! }.should == '<div id="an_id"></div>'
      quick_render { div :id => 12 }.should == '<div id="12"></div>'
      quick_render { hr.id 'an_id' }.should == '<hr id="an_id" />'
      quick_render { hr.an_id! }.should == '<hr id="an_id" />'
      quick_render { hr :id => 'an_id' }.should == '<hr id="an_id" />'
    end

    it 'should render #class' do
      quick_render { div.class 'an_class' }.should == '<div class="an_class"></div>'
      quick_render { div.an_class }.should == '<div class="an_class"></div>'
      quick_render { div :class => 'an_class' }.should == '<div class="an_class"></div>'
      quick_render { hr.class 'an_class' }.should == '<hr class="an_class" />'
      quick_render { hr.an_class }.should == '<hr class="an_class" />'
      quick_render { hr :class => 'an_class' }.should == '<hr class="an_class" />'

      quick_render { div.an_class.another_class }.should == '<div class="an_class another_class"></div>'
      quick_render { div.class 'an_class', 'another_class' }.should == '<div class="an_class another_class"></div>'
      quick_render { div :class => ['an_class', 'another_class'] }.should == '<div class="an_class another_class"></div>'
    end

    it "#data-.*" do
      quick_render { div('a').data_secret("I won't tell.") }.should == '<div data-secret="I won\'t tell.">a</div>'
    end

    it 'tags should have all the attributes' do
      builder.tags.each do |tag|
        builder.should be_respond_to(tag)
        tag_instance = builder.send(tag)
        (HammerBuilder::GLOBAL_ATTRIBUTES + HammerBuilder::EXTRA_ATTRIBUTES[tag]).each do |attr|
          tag_instance.should be_respond_to(attr)
        end
      end
    end

    it "should render correctly" do
      quick_render do
        xhtml5!
        html do
          head do
            title.an_id! 'a_title'
            meta.charset "utf-8"
          end
          body.id 'content' do
            text 'asd'
            div.left do
              raw 'asd'
              hr
            end
            br
            div.left do
              hr
              js 'asd'
              js 'asd', :cdata => true
            end
            comment 'asd'
          end
          comment 'asd'
        end
      end.should == '<?xml version="1.0" encoding="UTF-8"?>' + "\n" +
          '<!DOCTYPE html>' + "\n" +
          '<html xmlns="http://www.w3.org/1999/xhtml"><head><title id="an_id">a_title</title><meta charset="utf-8" />'+
          '</head><body id="content">asd<div class="left">asd<hr /></div><br /><div class="left"><hr />'+
          '<script type="text/javascript">asd</script><script type="text/javascript"><![CDATA[asd]]></script>'+
          '</div><!--asd--></body><!--asd--></html>'
    end

    it "#set variables" do
      r = builder.set_variables(:a => 'a') do |b|
        b.dive { p @a }
      end.to_xhtml!

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

  describe HammerBuilder::Formatted do
    let(:pool) { HammerBuilder::Pool.new HammerBuilder::Formatted }
    let(:builder) { pool.get }

    def quick_render &block
      builder.dive(&block).to_xhtml!
    end

    it "should be formatted" do
      quick_render { div { comment 'asd'; br }; p }.should == "\n<div>\n  <!--asd-->\n  <br />\n</div>\n<p></p>"
    end
  end
end
