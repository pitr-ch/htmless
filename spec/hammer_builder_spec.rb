require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe HammerBuilder do
  def super_subject
    self.class.ancestors[1].allocate.subject
  end

  describe 'object with HammerBuilder::Helper' do
    class AObject
      include HammerBuilder::Helper

      builder :render do |obj|
        @obj = obj
        div 'a'
      end
    end

    subject { AObject.new }

    describe 'methods' do
      subject { super_subject.class.instance_methods }
      it { should include(:render) }
    end

    describe '#render(builder)' do
      subject { super_subject.render(HammerBuilder::Standard.get).to_xhtml! }
      it { should == "<div>a</div>"}
    end
  end

  pending 'RedefinableClassTree'

  #  describe 'RedefinableClassTree' do
  #    let :klass do
  #      Class.new do
  #        extend HammerBuilder::RedefinableClassTree
  #      end
  #    end
  #
  #    describe '.define_class' do
  #      before do
  #        klass.define_class(:AClass) do
  #          def a_method
  #          end
  #        end
  #      end
  #
  #      it {  }
  #    end
  #  end

  describe HammerBuilder::Standard do
    describe 'Pool methods' do
      describe '.get' do
        it { HammerBuilder::Standard.get.should be_an_instance_of(HammerBuilder::Standard) }
        it { HammerBuilder::Formated.get.should be_an_instance_of(HammerBuilder::Formated) }
      end

      describe '#release!' do
        before do
          (@builder = HammerBuilder::Standard.get).release!
        end

        it 'should be same object' do
          @builder.should == HammerBuilder::Standard.get
        end
      end

      describe 'pools does not mix' do
        before { HammerBuilder::Standard.get.release! }
        it { HammerBuilder::Standard.pool_size.should == 1 }
        it { HammerBuilder::Formated.get.should be_an_instance_of(HammerBuilder::Formated) }
      end
    end

    describe 'available methods' do
      subject { HammerBuilder::Standard.instance_methods }

      (HammerBuilder::DOUBLE_TAGS + HammerBuilder::EMPTY_TAGS).each do |tag|
        it "should have method #{tag}" do
          should include(tag.to_sym)
        end

        describe tag do
          before { @builder = HammerBuilder::Standard.get }
          after { @builder.release! }
          subject { @builder.send(tag).methods }
          it "should include its attribute methods" do
            attrs = (HammerBuilder::GLOBAL_ATTRIBUTES + HammerBuilder::EXTRA_ATTRIBUTES[tag]).
                map {|attr| attr.to_sym}
            should include(*attrs)
          end
        end
      end

    end

    CONTENT = :'cc<>&cc'

    describe 'rendering' do
      describe '1' do
        subject do
          HammerBuilder::Formated.get.go_in do
            xhtml5!
            html do
              head { title }
              body do
                div CONTENT
                meta.http_equiv CONTENT
                p.content CONTENT
                div.id CONTENT
                div.data_id CONTENT
                div :id => CONTENT, :content => CONTENT
                div.attributes :id => CONTENT, :content => CONTENT
                div.attribute :newone, CONTENT
                div { text CONTENT }
                div[CONTENT].with { article CONTENT }
                js 'var < 1;'
                div do
                  strong :content
                  text :content
                end
              end
            end
          end.to_xhtml!.strip
        end

        it { should_not match(/cc<>&cc/) }
        it 'should render corectly' do
          should == (<<STR).strip
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title></title>
  </head>
  <body>
    <div>cc&lt;&gt;&amp;cc</div>
    <meta http-equiv="cc&lt;&gt;&amp;cc" />
    <p>cc&lt;&gt;&amp;cc</p>
    <div id="cc&lt;&gt;&amp;cc"></div>
    <div data-id="cc&lt;&gt;&amp;cc"></div>
    <div id="cc&lt;&gt;&amp;cc">cc&lt;&gt;&amp;cc</div>
    <div id="cc&lt;&gt;&amp;cc">cc&lt;&gt;&amp;cc</div>
    <div newone="cc&lt;&gt;&amp;cc"></div>
    <div>cc&lt;&gt;&amp;cc
    </div>
    <div id="cc&lt;&gt;&amp;cc">
      <article>cc&lt;&gt;&amp;cc</article>
    </div>
    <script type="text/javascript"><![CDATA[var < 1;]]>
    </script>
    <div>
      <strong>content</strong>content
    </div>
  </body>
</html>
STR
        end
      end
      describe '2' do
        subject do
          HammerBuilder::Formated.get.go_in do
            html do
              body do
                comment CONTENT
                cdata CONTENT
              end
            end
          end.to_xhtml!.strip
        end

        it 'should render corectly' do
          should == (<<STR).strip
<html xmlns="http://www.w3.org/1999/xhtml">
  <body>
    <!--cc<>&cc--><![CDATA[cc<>&cc]]>
  </body>
</html>
STR
        end
      end
    end
  end
end