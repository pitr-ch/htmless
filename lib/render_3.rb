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
    "onfocus", "onblur", "align", "char", "charoff", "lang", "dir", "valign"] # "xml:lang"

  # << faster then +
  # yield faster then block.call
  # accessing ivar is faster then accesing hash or constants
  # class_eval faster then define_method

  # TODO doctype
  # TODO comment
  # TODO add full attribute set
  # TODO YARD

  class ATag

    def initialize(builder)
      @builder = builder
      @output = builder.instance_eval { @output }
    end

    def open(tag, attributes = nil)
      @output << '<' << tag
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
      @output << " #{attribute}=\"" << CGI.escapeHTML(content) << '"'
    end


    (ATTRIBUTES).each do |attr|
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def #{attr}(content)
          @output << ' #{attr}="' << CGI.escapeHTML(content) << '"'
          self
        end
      RUBYCODE
    end

    class_eval <<-RUBYCODE, __FILE__, __LINE__
      def class(*classes)
        attribute 'class', classes.join(' ')
        self
      end
    RUBYCODE

    alias :[] :id
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
      @output << CGI.escapeHTML(@content) if @content
      @output << '</' << @stack.pop << '>'
      @content = nil
    end

    def with
      @output << '>'
      @content = nil
      @builder.current = nil
      yield
      @builder.flush
      @output << '</' << @stack.pop << '>'
      nil
    end

    (ATTRIBUTES + ['class']).each do |attr|
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def #{attr}(*args, &block)
          super *args
          return with(&block) if block
          self
        end
      RUBYCODE
    end

  end

  class Builder
    attr_accessor :current

    def initialize() # TODO tag classes
      @output = ""
      @stack = []
      @empty_tag = EmptyTag.new self
      @double_tag = DoubleTag.new self
      @current = nil
    end

    def text(text)
      @output << CGI.escapeHTML(text.to_s)
    end

    def raw(text)
      @output << text.to_s
    end

    def flush
      if @current
        @current.flush
        @current = nil
      end
    end

    def go_in(*variables, &block)
      instance_exec *variables, &block
    end

    DOUBLE_TAGS.each do |tag|
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def #{tag}(content_or_attributes = nil, attributes = nil, &block)
          flush
          @double_tag.open('#{tag}', content_or_attributes, attributes, &block)
        end
      RUBYCODE
    end

    EMPTY_TAGS.each do |tag|
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def #{tag}(attributes = nil)
          flush
          @empty_tag.open('#{tag}', attributes)
        end
      RUBYCODE
    end

    def to_s
      flush
      @output
    end
  end

end

