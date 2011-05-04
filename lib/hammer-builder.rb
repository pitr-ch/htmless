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

    # TODO documentation
    # TODO tests

    def self.define_class(klass_name, superclass_name = nil, &definition)
      raise "class: '#{klass_name}' already defined" if  respond_to? "#{klass_name}_class"

      define_singleton_method "#{klass_name}_class" do |builder|
        builder.instance_variable_get("@#{klass_name}_class") || begin
          klass = builder.send("#{klass_name}_class_definition", builder)
          builder.const_set klass_name.to_s.classify, klass rescue nil # FIXME why 's'.to_s.classify => '' ?
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

        @lt = '<'
        @gt = '>'
        @slash_lt = '</'
        @slash_gt = ' />'
        @space = ' '
        @space2 = '  '
        @newline = "\n"
        @quote = '"'
        @eql = '='
        @eql_quote = @eql + @quote

        set_tag
        set_attributes
      end

      def set_tag
        @tag = 'abstract'
      end

      def set_attributes
        self.rclass.attributes.each do |attr|
          instance_variable_set("@attr_#{attr}", " #{attr}=\"")
        end
      end

      def open(attributes = nil)
        @output << @lt << @tag
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
        @output << @space << attribute << @eql_quote << @builder.escape(content) << @quote
      end

      alias_method(:rclass, :class)

      def self.attributes
        # global HTML5 attributes
        [ 'accesskey','class','contenteditable','contextmenu','dir','draggable','dropzone','hidden','id','lang',
          'spellcheck','style','tabindex','title','onabort','onblur','oncanplay','oncanplaythrough','onchange',
          'onclick','oncontextmenu','oncuechange','ondblclick','ondrag','ondragend','ondragenter','ondragleave',
          'ondragover','ondragstart','ondrop','ondurationchange','onemptied','onended','onerror','onfocus','oninput',
          'oninvalid','onkeydown','onkeypress','onkeyup','onload','onloadeddata','onloadedmetadata','onloadstart',
          'onmousedown','onmousemove','onmouseout','onmouseover','onmouseup','onmousewheel','onpause','onplay',
          'onplaying','onprogress','onratechange','onreadystatechange','onreset','onscroll','onseeked','onseeking',
          'onselect','onshow','onstalled','onsubmit','onsuspend','ontimeupdate','onvolumechange','onwaiting']
      end

      def self.define_attributes
        attributes.each do |attr|
          next if instance_methods.include?(attr.to_sym)
          class_eval <<-RUBYCODE, __FILE__, __LINE__
            def #{attr}(content)
              @output << @attr_#{attr} << @builder.escape(content.to_s) << @quote
              self
            end
          RUBYCODE
        end
      end

      define_attributes

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
          @output << @attr_class << @builder.escape(@classes.join(@space)) << @quote
          @classes.clear
        end
        @output << @slash_gt
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
          @output << @attr_class << @builder.escape(@classes.join(@space)) << @quote
          @classes.clear
        end
        @output << @gt
        @output << @builder.escape(@content) if @content
        @output << @slash_lt << @stack.pop << @gt
        @content = nil
      end

      def with
        unless @classes.empty?
          @output << @attr_class << @builder.escape(@classes.join(@space)) << @quote
          @classes.clear
        end
        @output << @gt
        @content = nil
        @builder.current = nil
        yield
        @builder.flush
        @output << @slash_lt << @stack.pop << @gt
        nil
      end

      def self.define_attributes
        attributes.each do |attr|
          if instance_methods.include?(attr.to_sym)
            class_eval <<-RUBYCODE, __FILE__, __LINE__
              def #{attr}(*args, &block)
                super(*args, &nil)
                return with(&block) if block
                self
              end
            RUBYCODE
          else
            class_eval <<-RUBYCODE, __FILE__, __LINE__
              def #{attr}(content, &block)
                @output << @attr_#{attr} << @builder.escape(content.to_s) << @quote
                return with(&block) if block
                self
              end
            RUBYCODE
          end
        end
      end
    end

    class_inheritable_accessor :tags, :instance_writer => false
    self.tags = {}

    def self.define_tag(tag)
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def #{tag}(*args, &block)
          flush
          @#{tag}.open(*args, &block)
        end
      RUBYCODE
      self.tags[tag] = tag
    end

    attr_accessor :current

    def initialize() # TODO tag classes
      @output = ""
      @stack = []
      @current = nil
      tags.values.each do |klass|
        instance_variable_set(:"@#{klass}", self.class.send("#{klass}_class", self.class).new(self))
      end

      @comment_start = "<!--"
      @comment_end = '-->'
      @esc_amp = '&amp;'
      @esc_quot = '&quot;'
      @esc_lt = '&lt;'
      @esc_gt = '&gt;'
    end

    def text(text)
      @output << escape(text.to_s)
    end

    alias :[] :text

    def raw(text)
      @output << text.to_s
    end

    def comment(comment)
      @output << @comment_start << comment << @comment_end
    end

    def xml_version(version = '1.0', encoding = 'UTF-8')
      @output << "<?xml version=\"#{version}\" encoding=\"#{encoding}\"?>"
    end

    def doctype
      @output << "<!DOCTYPE html>"
    end

    def xhtml5!
      xml_version
      doctype
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

    def escape(string)
      string.gsub("&\"<>") do |ch|
        case ch
        when '&' then @esc_amp
        when '"' then @esc_quot
        when '<' then @esc_lt
        when '>' then @esc_gt
        end
      end
    end

  end

  module BuilderConstatns

    EXTRA_ATTRIBUTES = {
      "a" => ["href", "target", "ping", "rel", "media", "hreflang", "type"],
      "abbr" => [],
      "address" => [],
      "area" => ["alt", "coords", "shape", "href", "target", "ping", "rel", "media", "hreflang", "type"],
      "article" => [],
      "aside" => [],
      "audio" => ["src", "preload", "autoplay", "mediagroup", "loop", "controls"],
      "b" => [],
      "base" => ["href", "target"],
      "bdi" => [],
      "bdo" => [],
      "blockquote" => ["cite"],
      "body" => ["onafterprint", "onbeforeprint", "onbeforeunload", "onblur", "onerror", "onfocus", "onhashchange",
        "onload", "onmessage", "onoffline", "ononline", "onpagehide", "onpageshow", "onpopstate", "onredo", "onresize",
        "onscroll", "onstorage", "onundo", "onunload"],
      "br" => [],
      "button" => ["autofocus", "disabled", "form", "formaction", "formenctype", "formmethod", "formnovalidate",
        "formtarget", "name", "type", "value"],
      "canvas" => ["width", "height"],
      "caption" => [],
      "cite" => [],
      "code" => [],
      "col" => ["span"],
      "colgroup" => ["span"],
      "command" => ["type", "label", "icon", "disabled", "checked", "radiogroup"],
      "datalist" => ["option"],
      "dd" => [],
      "del" => ["cite", "datetime"],
      "details" => ["open"],
      "dfn" => [],
      "div" => [],
      "dl" => [],
      "dt" => [],
      "em" => [],
      "embed" => ["src", "type", "width", "height"],
      "fieldset" => ["disabled", "form", "name"],
      "figcaption" => [],
      "figure" => [],
      "footer" => [],
      "form" => ["action", "autocomplete", "enctype", "method", "name", "novalidate", "target"], # FIXME add "accept-charset"
      "h1" => [],
      "h2" => [],
      "h3" => [],
      "h4" => [],
      "h5" => [],
      "h6" => [],
      "head" => [],
      "header" => [],
      "hgroup" => [],
      "hr" => [],
      "html" => ["manifest"],
      "i" => [],
      "iframe" => ["src", "srcdoc", "name", "sandbox", "seamless", "width", "height"],
      "img" => ["alt", "src", "usemap", "ismap", "width", "height"],
      "input" => ["accept", "alt", "autocomplete", "autofocus", "checked", "dirname", "disabled", "form", "formaction",
        "formenctype", "formmethod", "formnovalidate", "formtarget", "height", "list", "max", "maxlength", "min",
        "multiple", "name", "pattern", "placeholder", "readonly", "required", "size", "src", "step", "type", "value",
        "width"],
      "ins" => ["cite", "datetime"],
      "kbd" => [],
      "keygen" => ["autofocus", "challenge", "disabled", "form", "keytype", "name"],
      "label" => ["form", "for"],
      "legend" => [],
      "li" => ["value"],
      "link" => ["href", "rel", "media", "hreflang", "type", "sizes"],
      "map" => ["name"],
      "mark" => [],
      "menu" => ["type", "label"],
      "meta" => ["name", "content", "charset"], # FIXME add "http-equiv"
      "meter" => ["value", "min", "max", "low", "high", "optimum", "form"],
      "nav" => [],
      "noscript" => [],
      "object" => ["data", "type", "name", "usemap", "form", "width", "height"],
      "ol" => ["reversed", "start"],
      "optgroup" => ["disabled", "label"],
      "option" => ["disabled", "label", "selected", "value"],
      "output" => ["for", "form", "name"],
      "p" => [],
      "param" => ["name", "value"],
      "pre" => [],
      "progress" => ["value", "max", "form"],
      "q" => ["cite"],
      "rp" => [],
      "rt" => [],
      "ruby" => [],
      "s" => [],
      "samp" => [],
      "script" => ["src", "async", "defer", "type", "charset"],
      "section" => [],
      "select" => ["autofocus", "disabled", "form", "multiple", "name", "required", "size"],
      "small" => [],
      "source" => ["src", "type", "media"],
      "span" => [],
      "strong" => [],
      "style" => ["media", "type", "scoped"],
      "sub" => [],
      "summary" => [],
      "sup" => [],
      "table" => ["border"],
      "tbody" => [],
      "td" => ["colspan", "rowspan", "headers"],
      "textarea" => ["autofocus", "cols", "disabled", "form", "maxlength", "name", "placeholder", "readonly",
        "required", "rows", "wrap"],
      "tfoot" => [],
      "th" => ["colspan", "rowspan", "headers", "scope"],
      "thead" => [],
      "time" => ["datetime", "pubdate"],
      "title" => [],
      "tr" => [],
      "track" => ["default", "kind", "label", "src", "srclang"],
      "u" => [],
      "ul" => [],
      "var" => [],
      "video" => ["src", "poster", "preload", "autoplay", "mediagroup", "loop", "controls", "width", "height"],
      "wbr" => []
    }

    DOUBLE_TAGS = [
      'a', 'abbr', 'address', 'article', 'aside', 'audio',
      'b', 'bdo', 'blockquote', 'body', 'button',
      'canvas', 'caption', 'cite', 'code', 'colgroup', 'command',
      'datalist', 'dd', 'del', 'details', 'dfn', 'div', 'dl', 'dt',
      'em',
      'fieldset', 'figure', 'footer', 'form',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'html', 'i',
      'iframe', 'ins', 'keygen', 'kbd', 'label', 'legend', 'li',
      'map', 'mark', 'meter',
      'nav', 'noscript',
      'object', 'ol', 'optgroup', 'option',
      'p', 'pre', 'progress',
      'q', 'ruby', 'rt', 'rp', 's',
      'samp', 'script', 'section', 'select', 'small', 'source', 'span',
      'strong', 'style', 'sub', 'sup',
      'table', 'tbody', 'td', 'textarea', 'tfoot',
      'th', 'thead', 'time', 'title', 'tr',
      'u', 'ul',
      'var', 'video'
    ]

    EMPTY_TAGS = [
      'area', 'base', 'br', 'col', 'embed',
      'hr', 'img', 'input', 'link', 'meta', 'param'
    ]

  end

  class Builder < AbstractBuilder

    (BuilderConstatns::DOUBLE_TAGS - ['html']).each do |tag|
      define_class tag, :abstract_double_tag do
        set_tag tag

        class_eval <<-RUBYCODE, __FILE__, __LINE__
          def self.attributes
            super + BuilderConstatns::EXTRA_ATTRIBUTES['#{tag}']
          end
        RUBYCODE

        define_attributes
      end

      define_tag(tag)
    end

    define_class :html, :abstract_double_tag do
      set_tag 'html'

      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def self.attributes
          super + ['xmlns'] + BuilderConstatns::EXTRA_ATTRIBUTES['html']
        end
      RUBYCODE

      define_attributes

      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def open(*args, &block)
          super(*args, &nil).xmlns('http://www.w3.org/1999/xhtml')
          block ? with(&block) : self
        end
      RUBYCODE
    end

    define_tag('html')

    BuilderConstatns::EMPTY_TAGS.each do |tag|
      define_class tag, :abstract_empty_tag do
        set_tag tag

        class_eval <<-RUBYCODE, __FILE__, __LINE__
          def self.attributes
            super + BuilderConstatns::EXTRA_ATTRIBUTES['#{tag}']
          end
        RUBYCODE

        define_attributes
      end

      define_tag(tag)
    end
  end

  class FormatedBuilder < Builder
    redefine_class :abstract_tag do
      def open(attributes = nil)
        @output << @newline << @space2 * @stack.size << @lt << @tag
        @builder.current = self
        attributes(attributes)
        self
      end
    end

    redefine_class :abstract_double_tag do
      def with
        unless @classes.empty?
          @output << @attr_class << @builder.escape(@classes.join(@space)) << @quote
          @classes.clear
        end
        @output << @gt
        @content = nil
        @builder.current = nil
        yield
        @builder.flush
        @output << @newline << @space2 * (@stack.size-1) << @slash_lt << @stack.pop << @gt
        nil
      end
    end
  end
end

