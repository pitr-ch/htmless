require 'cgi'

module Render3

  EMPTY_TAGS = [
    'area', 'base', 'br', 'col', 'embed', 'frame',
    'hr', 'img', 'input', 'link', 'meta', 'param'
  ]
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
  ATTRIBUTES = ["id", "class", "style", "title", "onclick", "ondblclick", "onmousedown", "onmouseup", "onmouseover",
    "onmousemove", "onmouseout", "onkeypress", "onkeydown", "onkeyup", "accesskey", "tabindex",
    "onfocus", "onblur", "align", "char", "charoff", "lang", "xml:lang", "dir", "valign"]

  # << faster then +
  # yield faster then block.call

  # TODO doctype
  # TODO comment
  # TODO add full attribute set
  # TODO YARD

  module Tools
    extend self
    
    def escape(text)
      CGI.escapeHTML(text)
    end
  end

  class ATag    
      
    def initialize(builder)
      @builder = builder
      @output = builder.instance_eval { @output }
    end

    def open(tag, attributes = nil)
      @output << '<' << tag
      @builder.open_tag = self
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
      @output << " #{attribute}=\"" << Tools.escape(content) << '"'
    end

    (ATTRIBUTES).each do |attr|
      define_method(attr) do |content|
        @output << " #{attr}=\"" << Tools.escape(content) << '"'
        self
      end
    end

    def class(*classes)
        attribute 'class', classes.join(' ')
        self
      end

      def [](id)
        id(id)
      end

    end

    class EmptyTag < ATag
      def flush
        @output << ' />'
        nil
      end
    end

    class DoubleTag < ATag
      def initialize(builder)
        super
        @stack = builder.instance_eval { @stack }
        @content = nil
      end

      def open(tag, content_or_attributes, attributes, &block)
        if content_or_attributes.kind_of?(String)
          @content = content_or_attributes
        else
          attributes = content_or_attributes
        end
        super tag, attributes
        @stack << tag
        if block
          with &block
        else
          self
        end
      end

      def flush
        @output << '>' 
        @output << Tools.escape(@content) if @content
        @output << '</' << @stack.pop << '>'        
        @content = nil
      end

      def with
        @output << '>'
        @content = nil
        @builder.open_tag = nil
        yield
        @builder.flush
        @output << '</' << @stack.pop << '>'
        nil
      end

      (ATTRIBUTES + ['class']).each do |attr|
        define_method(attr) do |*args, &block|
          super *args
          return with(&block) if block
          self
        end
      end
    end

    class Builder

      def initialize() # TODO tag classes
        @output = ""
        @stack = []
        @empty_tag = EmptyTag.new self
        @double_tag = DoubleTag.new self
        @open_tag = nil
      end

      def text(text)
        @output << Tools.escape(text.to_s)
      end

      def raw(text)
        @output << text.to_s
      end

      def open_tag=(tag)        
        @open_tag = tag
      end

      def current
        @open_tag
      end

      def flush
        if @open_tag
          @open_tag.flush
          @open_tag = nil          
        end
      end

      DOUBLE_TAGS.each do |tag|
        define_method(tag) do |content_or_attributes = nil, attributes = nil, &block|
          flush
          @double_tag.open(tag, content_or_attributes, attributes, &block)
        end
      end

      EMPTY_TAGS.each do |tag|
        define_method(tag) do |attributes = nil|
          flush
          @empty_tag.open(tag, attributes)
        end
      end

      def to_s
        flush
        @output
      end
    end

  end

