require 'cgi'

module Render2

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
  ATTRIBUTES=[
    'id', 'class', 'style', 'title'
  ]

  # << faster then +
  # yield faster then block.call

  # pridat attributy jako hash a content v tagu a bloky attributum
  # pozdejsi vlozeni title


  class Output < String
    def escape(text)
      self.<< CGI.escapeHTML(text)
    end
  end

  class Builder
    def initialize(empty_tag_class = EmptyTag, double_tag_class = DoubleTag) # TODO tag classes
      @output = Output.new
      @stack = []
      @empty_tag = empty_tag_class.new self
      @double_tag = double_tag_class.new self
    end

    def text(text)
      @output.escape(text)
    end

    def raw(text)
      @output << text
    end

    def close_all
      @empty_tag.close
      @double_tag.close
    end

    DOUBLE_TAGS.each do |tag|
      define_method(tag) {|content = nil| @double_tag.open(tag, content) }
    end
    EMPTY_TAGS.each do |tag|
      define_method(tag) { @empty_tag.open(tag) }
    end

    def to_s
      close_all
      @output
    end
  end

  class ATag
    def initialize(builder)
      @builder = builder
      @output = builder.instance_eval { @output }
      @inside = false
      @classes = []
    end

    def open(tag, *args)
      close_all
      @inside = true
      @output << '<' << tag
      self
    end

    def attribute(attribute, content)
      @output << " #{attribute}=\""
      @output.escape content
      @output << '"'
    end

    def close_classes
      attribute 'class', @classes.join(' ') unless @classes.empty?
      @classes.clear
    end

    (ATTRIBUTES - ['class']).each do |attr|
      define_method(attr) do |content|
        @output << " #{attr}=\""
        @output.escape content
        @output << '"'
        self
      end
    end

    def classes(*classes)
      @classes.push [*classes]
      self
    end

    private

    def close_all
      @builder.close_all
    end
  end

  class EmptyTag < ATag
    def close
      close_classes
      @output << ' />' if @inside
      @inside = false
      nil
    end
  end

  class DoubleTag < ATag
    def initialize(builder)
      super
      @stack = builder.instance_eval { @stack }
      @open = false
      @content = nil
    end

    def open(tag, content = nil)
      super tag
      @open = true
      @content = content
      @stack << tag
      self
    end

    def close
      close_classes
      @output << '>' if @inside
      @output.escape(@content) if @content
      @output << '</' << @stack.pop << '>' if @open
      @inside = @open = false
      @content = nil
    end

    def with
      close_classes
      @output << '>'
      @open = @inside = false
      @content = nil
      yield
      close_all
      @output << '</' << @stack.pop << '>'
      nil
    end
  end
end

