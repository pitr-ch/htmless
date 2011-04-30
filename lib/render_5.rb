require 'cgi'
require "nokogiri"

module Render5

  { "area"=>{:class=>:Area, :double=>false},
    "base"=>{:class=>:Base, :double=>false},
    "br"=>{:class=>:Br, :double=>false},
    "col"=>{:class=>:Col, :double=>false},
    "embed"=>{:class=>:Embed, :double=>false},
    "frame"=>{:class=>:Frame, :double=>false},
    "hr"=>{:class=>:Hr, :double=>false},
    "img"=>{:class=>:Img, :double=>false},
    "input"=>{:class=>:Input, :double=>false},
    "link"=>{:class=>:Link, :double=>false},
    "meta"=>{:class=>:Meta, :double=>false},
    "param"=>{:class=>:Param, :double=>false},
    "a"=>{:class=>:A, :double=>true},
    "abbr"=>{:class=>:Abbr, :double=>true},
    "acronym"=>{:class=>:Acronym, :double=>true},
    "address"=>{:class=>:Address, :double=>true},
    "article"=>{:class=>:Article, :double=>true},
    "aside"=>{:class=>:Aside, :double=>true},
    "audio"=>{:class=>:Audio, :double=>true},
    "b"=>{:class=>:B, :double=>true},
    "bdo"=>{:class=>:Bdo, :double=>true},
    "big"=>{:class=>:Big, :double=>true},
    "blockquote"=>{:class=>:Blockquote, :double=>true},
    "body"=>{:class=>:Body, :double=>true},
    "button"=>{:class=>:Button, :double=>true},
    "canvas"=>{:class=>:Canvas, :double=>true},
    "caption"=>{:class=>:Caption, :double=>true},
    "center"=>{:class=>:Center, :double=>true},
    "cite"=>{:class=>:Cite, :double=>true},
    "code"=>{:class=>:Code, :double=>true},
    "colgroup"=>{:class=>:Colgroup, :double=>true},
    "command"=>{:class=>:Command, :double=>true},
    "datalist"=>{:class=>:Datalist, :double=>true},
    "dd"=>{:class=>:Dd, :double=>true},
    "del"=>{:class=>:Del, :double=>true},
    "details"=>{:class=>:Details, :double=>true},
    "dfn"=>{:class=>:Dfn, :double=>true},
    "dialog"=>{:class=>:Dialog, :double=>true},
    "div"=>{:class=>:Div, :double=>true},
    "dl"=>{:class=>:Dl, :double=>true},
    "dt"=>{:class=>:Dt, :double=>true},
    "em"=>{:class=>:Em, :double=>true},
    "fieldset"=>{:class=>:Fieldset, :double=>true},
    "figure"=>{:class=>:Figure, :double=>true},
    "footer"=>{:class=>:Footer, :double=>true},
    "form"=>{:class=>:Form, :double=>true},
    "frameset"=>{:class=>:Frameset, :double=>true},
    "h1"=>{:class=>:H1, :double=>true},
    "h2"=>{:class=>:H2, :double=>true},
    "h3"=>{:class=>:H3, :double=>true},
    "h4"=>{:class=>:H4, :double=>true},
    "h5"=>{:class=>:H5, :double=>true},
    "h6"=>{:class=>:H6, :double=>true},
    "head"=>{:class=>:Head, :double=>true},
    "header"=>{:class=>:Header, :double=>true},
    "hgroup"=>{:class=>:Hgroup, :double=>true},
    "html"=>{:class=>:Html, :double=>true},
    "i"=>{:class=>:I, :double=>true},
    "iframe"=>{:class=>:Iframe, :double=>true},
    "ins"=>{:class=>:Ins, :double=>true},
    "keygen"=>{:class=>:Keygen, :double=>true},
    "kbd"=>{:class=>:Kbd, :double=>true},
    "label"=>{:class=>:Label, :double=>true},
    "legend"=>{:class=>:Legend, :double=>true},
    "li"=>{:class=>:Li, :double=>true},
    "map"=>{:class=>:Map, :double=>true},
    "mark"=>{:class=>:Mark, :double=>true},
    "meter"=>{:class=>:Meter, :double=>true},
    "nav"=>{:class=>:Nav, :double=>true},
    "noframes"=>{:class=>:Noframes, :double=>true},
    "noscript"=>{:class=>:Noscript, :double=>true},
    "object"=>{:class=>:Object, :double=>true},
    "ol"=>{:class=>:Ol, :double=>true},
    "optgroup"=>{:class=>:Optgroup, :double=>true},
    "option"=>{:class=>:Option, :double=>true},
    "p"=>{:class=>:P, :double=>true},
    "pre"=>{:class=>:Pre, :double=>true},
    "progress"=>{:class=>:Progress, :double=>true},
    "q"=>{:class=>:Q, :double=>true},
    "ruby"=>{:class=>:Ruby, :double=>true},
    "rt"=>{:class=>:Rt, :double=>true},
    "rp"=>{:class=>:Rp, :double=>true},
    "s"=>{:class=>:S, :double=>true},
    "samp"=>{:class=>:Samp, :double=>true},
    "script"=>{:class=>:Script, :double=>true},
    "section"=>{:class=>:Section, :double=>true},
    "select"=>{:class=>:Select, :double=>true},
    "small"=>{:class=>:Small, :double=>true},
    "source"=>{:class=>:Source, :double=>true},
    "span"=>{:class=>:Span, :double=>true},
    "strike"=>{:class=>:Strike, :double=>true},
    "strong"=>{:class=>:Strong, :double=>true},
    "style"=>{:class=>:Style, :double=>true},
    "sub"=>{:class=>:Sub, :double=>true},
    "sup"=>{:class=>:Sup, :double=>true},
    "table"=>{:class=>:Table, :double=>true},
    "tbody"=>{:class=>:Tbody, :double=>true},
    "td"=>{:class=>:Td, :double=>true},
    "textarea"=>{:class=>:Textarea, :double=>true},
    "tfoot"=>{:class=>:Tfoot, :double=>true},
    "th"=>{:class=>:Th, :double=>true},
    "thead"=>{:class=>:Thead, :double=>true},
    "time"=>{:class=>:Time, :double=>true},
    "title"=>{:class=>:Title, :double=>true},
    "tr"=>{:class=>:Tr, :double=>true},
    "tt"=>{:class=>:Tt, :double=>true},
    "u"=>{:class=>:U, :double=>true},
    "ul"=>{:class=>:Ul, :double=>true},
    "var"=>{:class=>:Var, :double=>true},
    "video"=>{:class=>:Video, :double=>true}}

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

  # TODO add full attribute set
  # TODO YARD
  # TODO class for each tag?
  # TODO xmlns="http://www.w3.org/1999/xhtml" to hml tag

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
      @output << ' ' << attribute << '="' << CGI.escapeHTML(content) << '"'
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

    def to_s(options = {})
      flush
      out = unless options[:format]
        @output
      else
        indent = options[:format].kind_of?(Integer) ? options[:format] : 2
        Nokogiri::XML::DocumentFragment.parse(@output).to_xml(:indent => indent)
      end
      if options[:head]
        '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + '<!DOCTYPE html>' + "\n" + out
      else out
      end
    end
  end

end

