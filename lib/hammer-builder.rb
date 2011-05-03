require 'cgi'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/string/inflections'

module Hammer
  class AbstractBuilder


    #  ATTRIBUTES = ["id", "class", "style", "title", "onclick", "ondblclick", "onmousedown", "onmouseup", "onmouseover",
    #    "onmousemove", "onmouseout", "onkeypress", "onkeydown", "onkeyup", "accesskey", "tabindex",
    #    "onfocus", "onblur", "align", "char", "charoff", "lang", "dir", "valign"] # "xml:lang"

    # << faster then +
    # yield faster then block.call
    # accessing ivar is faster then accesing hash or constants
    # class_eval faster then define_method

    # TODO add full attribute set
    # TODO YARD
    # TODO xmlns="http://www.w3.org/1999/xhtml" to html tag

    def self.define_class(klass_name, superclass_name = nil, &definition)
      raise "class: '#{klass_name}' already defined" if  respond_to? "#{klass_name}_class"

      define_singleton_method "#{klass_name}_class" do |builder|
        builder.instance_variable_get("@#{klass_name}_class") || begin
          klass = builder.send("#{klass_name}_class_definition", builder)
          builder.const_set klass_name.to_s.classify, klass
          builder.instance_variable_set("@#{klass_name}_class", klass)
        end
      end

      define_singleton_method "#{klass_name}_class_definition" do |builder|
        superclass = if superclass_name
          builder.send "#{superclass_name}_class", builder
        else
          Object
        end
        Class.new(superclass, &definition)
      end
    end

    def self.redefine_class(klass_name, &definition)
      raise "class: '#{klass_name}' not defined" unless respond_to? "#{klass_name}_class"

      define_singleton_method "#{klass_name}_class_definition" do |builder|        
        Class.new(super(builder), &definition)
      end
    end

    define_class :abstract_tag do
      def self.attributes
        ["id", "class", "style", "title"]
      end

      def self.set_tag(tag)
        class_eval <<-RUBYCODE, __FILE__, __LINE__
          def set_tag
            @tag = '#{tag}'
          end
        RUBYCODE
      end

      def initialize(builder)
        @builder = builder
        @output = builder.instance_eval { @output }
        @stack = builder.instance_eval { @stack }
        @classes = []
        set_tag
      end

      def set_tag
        @tag = 'abstract'
      end

      def open(attributes = nil)
        @output << '<' << @tag
        @builder.current = self
        attributes(attributes)
        self
      end

      def attributes(attrs)
        return self unless attrs
        attrs.each do |attr, value|
          __send__(attr, *value)
        end
        self
      end

      def attribute(attribute, content)
        @output << ' ' << attribute << '="' << CGI.escapeHTML(content) << '"'
      end

      alias_method(:rclass, :class)

      attributes.each do |attr|
        class_eval <<-RUBYCODE, __FILE__, __LINE__
          def #{attr}(content)
            @output << ' #{attr}="' << CGI.escapeHTML(content.to_s) << '"'
            self
          end
        RUBYCODE
      end

      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def class(*classes)
          @classes.push(*classes)          
          self
        end
      RUBYCODE

      alias :[] :id
    end

    define_class :abstract_empty_tag, :abstract_tag do
      def flush
        unless @classes.empty?
          @output << ' class="' << CGI.escapeHTML(@classes.join(' ')) << '"'
          @classes.clear
        end
        @output << ' />'
        nil
      end
    end

    define_class :abstract_double_tag, :abstract_tag do
      # defined by class_eval because there is a super calling, causing error:
      #  super from singleton method that is defined to multiple classes is not supported;
      #  this will be fixed in 1.9.3 or later (NotImplementedError)
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def initialize(builder)
          super
          @content = nil
        end

        def open(content_or_attributes = nil, attributes = nil, &block)
          if content_or_attributes.kind_of?(String)
            @content = content_or_attributes
          else
            attributes = content_or_attributes
          end
          super attributes
          @stack << @tag
          if block
            with &block
          else
            self
          end
        end
      RUBYCODE

      def flush
        unless @classes.empty?
          @output << ' class="' << CGI.escapeHTML(@classes.join(' ')) << '"'
          @classes.clear
        end
        @output << '>'
        @output << CGI.escapeHTML(@content) if @content
        @output << '</' << @stack.pop << '>'
        @content = nil
      end

      def with
        unless @classes.empty?
          @output << ' class="' << CGI.escapeHTML(@classes.join(' ')) << '"'
          @classes.clear
        end
        @output << '>'
        @content = nil
        @builder.current = nil
        yield
        @builder.flush
        @output << '</' << @stack.pop << '>'
        nil
      end

      attributes.each do |attr|
        # TODO super may be inlined ...
        class_eval <<-RUBYCODE, __FILE__, __LINE__
          def #{attr}(*args, &block)
            super *args
            return with(&block) if block
            self
          end
        RUBYCODE
      end
    end

    class_inheritable_array :tags, :instance_writer => false

    def self.define_tag_class(klass_name, a_superclass_name = nil, &definition)
      define_class(klass_name, a_superclass_name, &definition)
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def #{klass_name}(*args, &block)
          flush
          @#{klass_name}.open(*args, &block)
        end
      RUBYCODE
      self.tags = [klass_name]
    end


    attr_accessor :current

    def initialize() # TODO tag classes
      @output = ""
      @stack = []
      @current = nil
      tags.each do |tag|
        instance_variable_set(:"@#{tag}", self.class.send("#{tag}_class", self.class).new(self))
      end
    end

    def text(text)
      @output << CGI.escapeHTML(text.to_s)
    end

    alias :[] :text

    def raw(text)
      @output << text.to_s
    end

    def comment(comment)
      @output << "<!--" << comment << '-->'
    end

    def flush
      if @current
        @current.flush
        @current = nil
      end
    end

    def reset
      flush
      @output.clear
      @stack.clear
    end

    def go_in(*variables, &block)
      instance_exec *variables, &block
      self
    end

    def to_html()
      flush
      @output
    end

  end

  class Builder < AbstractBuilder

    DOUBLE_TAGS = [
      'a', 'abbr', 'acronym', 'address', 'article', 'aside', 'audio',
      'b', 'bdo', 'big', 'blockquote', 'body', 'button',
      'canvas', 'caption', 'center', 'cite', 'code', 'colgroup', 'command',
      'datalist', 'dd', 'del', 'details', 'dfn', 'dialog', 'div', 'dl', 'dt',
      'em',
      'fieldset', 'figure', 'footer', 'form', 'frameset',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'html', 'i',
      'iframe', 'ins', 'keygen', 'kbd', 'label', 'legend', 'li',
      'map', 'mark', 'meter',
      'nav', 'noframes', 'noscript',
      'object', 'ol', 'optgroup', 'option',
      'p', 'pre', 'progress',
      'q', 'ruby', 'rt', 'rp', 's',
      'samp', 'script', 'section', 'select', 'small', 'source', 'span', 'strike',
      'strong', 'style', 'sub', 'sup',
      'table', 'tbody', 'td', 'textarea', 'tfoot',
      'th', 'thead', 'time', 'title', 'tr', 'tt',
      'u', 'ul',
      'var', 'video'
    ]

    DOUBLE_TAGS.each do |tag|
      define_tag_class tag, :abstract_double_tag do
        set_tag tag
      end
    end

    EMPTY_TAGS = [
      'area', 'base', 'br', 'col', 'embed', 'frame',
      'hr', 'img', 'input', 'link', 'meta', 'param'
    ]

    EMPTY_TAGS.each do |tag|
      define_tag_class tag, :abstract_empty_tag do
        set_tag tag
      end
    end
  end

  class FormatedBuilder < Builder
    redefine_class :abstract_tag do
      def open(attributes = nil)
        @output << "\n" << '  ' * @stack.size << '<' << @tag
        @builder.current = self
        attributes(attributes)
        self
      end
    end

    redefine_class :abstract_double_tag do
      def with
        unless @classes.empty?
          @output << ' class="' << CGI.escapeHTML(@classes.join(' ')) << '"'
          @classes.clear
        end
        @output << '>'
        @content = nil
        @builder.current = nil
        yield
        @builder.flush
        @output << "\n" << '  ' * (@stack.size-1) << '</' << @stack.pop << '>'
        nil
      end
    end
  end
end

