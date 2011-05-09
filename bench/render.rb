require 'cgi'

module Render

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
  # CGI.escapeHTML(content.to_s)

  # rozdelit tagy
  # pridat attributy jako hash a content v tagu a bloky attributum
  # pozdejsi vlozeni title


  class Output < String
    def escape(text)
      self.<< CGI.escapeHTML(text)
    end
  end

  class Builder
    def initialize()
      @output = Output.new
      @stack = []
      @tag = Tag.new self
    end

    def text(text)
      @output << CGI.escapeHTML(text)
    end

    DOUBLE_TAGS.each do |tag|
      define_method(tag) {|content = nil| @tag.open_double tag, content }
    end
    EMPTY_TAGS.each do |tag|
      define_method(tag) { @tag.open_empty(tag) }
    end

    def to_s
      @tag.close
      @output
    end
  end

  class Tag
    def initialize(builder)
      @builder = builder
      @output = builder.instance_eval { @output }
      @stack = builder.instance_eval { @stack }

      @inside_empty = false
      @inside_double = false
      @open_double = false
      @content = nil
    end

    def open_double(tag, content = nil)
      close
      @open_double = true
      @inside_double = true
      @content = content

      @stack.push tag
      @output << '<' << tag
      self
    end

    def open_empty(tag)
      close

      @inside_empty = true
      @output << '<' << tag
      self
    end

    def close
      @output << ' />' if @inside_empty
      @output << '>' if @inside_double
      @output.escape(@content) if @content
      @output << '</' << @stack.pop << ">" << '' if @open_double
      @inside_empty = @inside_double = @open_double = false
      @content = nil
    end

    def with
      @output << ">"
      @inside_double = false
      @open_double = false
      yield
      close
      @output << '</' << @stack.pop << ">"
      nil
    end

    # attributes

    def id(id)
      @output << ' id="' << id << '"'
      self
    end

    def klass(klass)
      @output << ' class="' << klass << '"'
      self
    end
  end

end