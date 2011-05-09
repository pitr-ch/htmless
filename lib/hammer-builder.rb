require 'cgi'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/string/inflections'

module HammerBuilder
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
    "form" => ["action", "autocomplete", "enctype", "method", "name", "novalidate", "target", 'accept_charset'], 
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
    "meta" => ["name", "content", "charset", "http_equiv"],
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
    'a', 'abbr',  'article', 'aside', 'audio', 'address', 
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

  LT = '<'
  GT = '>'
  SLASH_LT = '</'
  SLASH_GT = ' />'
  SPACE = ' '
  MAX_LEVELS = 300
  SPACES = Array.new(MAX_LEVELS) {|i| '  ' * i }
  NEWLINE = "\n"
  QUOTE = '"'
  EQL = '='
  EQL_QUOTE = EQL + QUOTE
  COMMENT_START = '<!--'
  COMMENT_END = '-->'

  module Helper
    def self.included(base)
      super
      base.extend ClassMethods
    end

    module ClassMethods
      def builder(method, &build_block)
        define_method(method) do |builder|
          builder.go_in(self, &build_block)
        end
      end
    end
  end

  module RedefinableClassTree
    def define_class(klass_name, superclass_name = nil, &definition)
      klass_name = class_name(klass_name)
      superclass_name = class_name(superclass_name) if superclass_name

      raise "class: '#{klass_name}' already defined" if  respond_to? method_class(klass_name)

      define_singleton_method method_class(klass_name) do |builder|
        builder.instance_variable_get("@#{method_class(klass_name)}") || begin
          klass = builder.send(method_class_definition(klass_name), builder)          
          builder.const_set klass_name, klass
          builder.instance_variable_set("@#{method_class(klass_name)}", klass)
        end
      end

      define_singleton_method method_class_definition(klass_name) do |builder|
        superclass = if superclass_name
          builder.send method_class(superclass_name), builder
        else
          Object
        end
        Class.new(superclass, &definition)
      end
    end

    def extend_class(klass_name, &definition)
      raise "class: '#{klass_name}' not defined" unless respond_to? method_class(klass_name)

      define_singleton_method method_class_definition(klass_name) do |builder|
        Class.new(super(builder), &definition)
      end
    end

    private

    def class_name(klass)
      klass.to_s.camelize
    end

    def method_class(klass)
      "#{klass.to_s.underscore}_class"
    end

    def method_class_definition(klass)
      "#{method_class(klass)}_definition"
    end
  end

  module Pool
    def self.included(base)
      super
      base.extend ClassMethods
    end
    
    module ClassMethods
      def get
        mutex.synchronize do
          if free_builders.empty?
            new
          else
            free_builders.pop
          end
        end
      end

      def release(builder)
        builder.reset
        mutex.synchronize do
          free_builders.push builder
        end
      end

      private
      
      def mutex
        @mutex ||= Mutex.new
      end

      def free_builders
        @free_builders ||= []
      end
    end

    def release!
      self.class.release(self)
    end
  end

  class Abstract
    extend RedefinableClassTree
    include Pool

    # << faster then +
    # yield faster then block.call
    # accessing ivar and constant is faster then accesing hash or cvar
    # class_eval faster then define_method
    # beware of strings in methods -> creates a lot of garbage

    define_class :AbstractTag do
      def initialize(builder)
        @builder = builder
        @output = builder.instance_eval { @output }
        @stack = builder.instance_eval { @stack }
        @classes = []
        set_tag
      end

      def open(attributes = nil)
        @output << LT << @tag
        @builder.current = self
        attributes(attributes)
        default
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
        @output << SPACE << attribute << EQL_QUOTE << CGI.escapeHTML(content) << QUOTE
      end

      alias_method(:rclass, :class)

      class_inheritable_array :_attributes, :instance_writer => false, :instance_reader => false

      def self.attributes
        self._attributes
      end
      
      def method_missing(method, *args, &block)
        if method.to_s =~ /data_([a-z_]+)/
          self.rclass.attributes = [method.to_s]
          self.send method, *args, &block
        else
          super
        end
      end

      protected

      def self.set_tag(tag)
        class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
          def set_tag
            @tag = '#{tag}'
          end
        RUBYCODE
      end

      def default
      end

      def self.define_attributes
        attributes.each do |attr|
          next if instance_methods.include?(attr.to_sym)
          class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
            def #{attr}(content)
              @output << ATTR_#{attr.upcase} << CGI.escapeHTML(content.to_s) << QUOTE
              self
            end
          RUBYCODE
        end
        define_attribute_constants
      end

      def self.define_attribute_constants
        attributes.each do |attr|
          const = "attr_#{attr}".upcase
          HammerBuilder.const_set const, " #{attr.gsub('_', '-')}=\"" unless HammerBuilder.const_defined?(const)
        end
      end

      def self.attributes=(attributes)
        self._attributes = attributes
        define_attributes
      end

      def flush_classes
        unless @classes.empty?
          @output << ATTR_CLASS << CGI.escapeHTML(@classes.join(SPACE)) << QUOTE
          @classes.clear
        end
      end

      def set_tag
        @tag = 'abstract'
      end

      public

      # global HTML5 attributes
      self.attributes = [
        'accesskey','class','contenteditable','contextmenu','dir','draggable','dropzone','hidden','id','lang',
        'spellcheck','style','tabindex','title','onabort','onblur','oncanplay','oncanplaythrough','onchange',
        'onclick','oncontextmenu','oncuechange','ondblclick','ondrag','ondragend','ondragenter','ondragleave',
        'ondragover','ondragstart','ondrop','ondurationchange','onemptied','onended','onerror','onfocus','oninput',
        'oninvalid','onkeydown','onkeypress','onkeyup','onload','onloadeddata','onloadedmetadata','onloadstart',
        'onmousedown','onmousemove','onmouseout','onmouseover','onmouseup','onmousewheel','onpause','onplay',
        'onplaying','onprogress','onratechange','onreadystatechange','onreset','onscroll','onseeked','onseeking',
        'onselect','onshow','onstalled','onsubmit','onsuspend','ontimeupdate','onvolumechange','onwaiting'
      ]

      alias :[] :id

      class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
        def class(*classes)
          @classes.push(*classes)
          self
        end
      RUBYCODE
    end

    define_class :AbstractEmptyTag, :AbstractTag do
      def flush
        flush_classes
        @output << SLASH_GT
        nil
      end
    end

    define_class :AbstractDoubleTag, :AbstractTag do
      # defined by class_eval because there is a super calling, causing error:
      #  super from singleton method that is defined to multiple classes is not supported;
      #  this will be fixed in 1.9.3 or later (NotImplementedError)
      class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
        def initialize(builder)
          super
          @content = nil
        end

        def open(*args, &block)
          attributes = if args.last.is_a?(Hash)
            args.pop
          end
          content args[0]
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
        flush_classes
        @output << GT
        @output << CGI.escapeHTML(@content) if @content
        @output << SLASH_LT << @stack.pop << GT
        @content = nil
      end

      def content(content)
        @content = content.to_s
        self
      end

      def with
        flush_classes
        @output << GT
        @content = nil
        @builder.current = nil
        #        yield
        if (content = yield).is_a?(String)
          @output << CGI.escapeHTML(content)
        end
        @builder.flush
        @output << SLASH_LT << @stack.pop << GT
        nil
      end

      protected

      def self.define_attributes
        attributes.each do |attr|
          next if instance_methods(false).include?(attr.to_sym)
          if instance_methods.include?(attr.to_sym)
            class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
              def #{attr}(*args, &block)
                super(*args, &nil)
                return with(&block) if block
                self
              end
            RUBYCODE
          else
            class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
              def #{attr}(content, &block)
                @output << ATTR_#{attr.upcase} << CGI.escapeHTML(content.to_s) << QUOTE
                return with(&block) if block
                self
              end
            RUBYCODE
          end
        end
        define_attribute_constants
      end
    end

    class_inheritable_accessor :tags, :instance_writer => false
    self.tags = {}

    protected

    def self.define_tag(tag)
      class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
        def #{tag}(*args, &block)
          flush
          @#{tag}.open(*args, &block)
        end
      RUBYCODE
      self.tags[tag] = tag
    end

    public

    attr_accessor :current

    def initialize()
      @output = ""
      @stack = []
      @current = nil
      tags.values.each do |klass|
        instance_variable_set(:"@#{klass}", self.class.send("#{klass}_class", self.class).new(self))
      end
    end

    def text(text)
      @output << CGI.escapeHTML(text.to_s)
    end

    def raw(text)
      @output << text.to_s
    end

    def comment(comment)
      @output << COMMENT_START << comment << COMMENT_END
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

    def reset
      flush
      @output.clear
      @stack.clear
    end

    def go_in(*variables, &block)
      instance_exec *variables, &block
      self
    end

    def to_xhtml()
      flush
      @output.clone
    end

    def to_xhtml!
      r = to_xhtml
      release!
      r
    end

    def flush
      if @current
        @current.flush
        @current = nil
      end
    end
  end

  class Standard < Abstract

    (DOUBLE_TAGS - ['html']).each do |tag|
      define_class tag.camelize , :AbstractDoubleTag do
        set_tag tag
        self.attributes = EXTRA_ATTRIBUTES[tag]
      end

      define_tag(tag)
    end

    define_class :Html, :AbstractDoubleTag do
      set_tag 'html'
      self.attributes = ['xmlns'] + EXTRA_ATTRIBUTES['html']

      def default
        xmlns('http://www.w3.org/1999/xhtml')
      end
    end

    define_tag('html')

    EMPTY_TAGS.each do |tag|
      define_class tag.camelize, :AbstractEmptyTag do
        set_tag tag
        self.attributes = EXTRA_ATTRIBUTES[tag]
      end

      define_tag(tag)
    end
  end

  class Formated < Standard
    extend_class :AbstractTag do
      def open(attributes = nil)
        @output << NEWLINE << SPACES.fetch(@stack.size, SPACE) << LT << @tag
        @builder.current = self
        attributes(attributes)
        default
        self
      end
    end

    extend_class :AbstractDoubleTag do
      def with
        flush_classes
        @output << GT
        @content = nil
        @builder.current = nil
        yield
        @builder.flush
        @output << NEWLINE << SPACES.fetch(@stack.size-1, SPACE) << SLASH_LT << @stack.pop << GT
        nil
      end
    end
  end
end

