require 'cgi'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/string/inflections'
require 'hammer_builder/dynamic_classes'

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
  
  GLOBAL_ATTRIBUTES = [
    'accesskey','class','contenteditable','contextmenu','dir','draggable','dropzone','hidden','id','lang',
    'spellcheck','style','tabindex','title','onabort','onblur','oncanplay','oncanplaythrough','onchange',
    'onclick','oncontextmenu','oncuechange','ondblclick','ondrag','ondragend','ondragenter','ondragleave',
    'ondragover','ondragstart','ondrop','ondurationchange','onemptied','onended','onerror','onfocus','oninput',
    'oninvalid','onkeydown','onkeypress','onkeyup','onload','onloadeddata','onloadedmetadata','onloadstart',
    'onmousedown','onmousemove','onmouseout','onmouseover','onmouseup','onmousewheel','onpause','onplay',
    'onplaying','onprogress','onratechange','onreadystatechange','onreset','onscroll','onseeked','onseeking',
    'onselect','onshow','onstalled','onsubmit','onsuspend','ontimeupdate','onvolumechange','onwaiting'
  ]

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

  LT = '<'.freeze
  GT = '>'.freeze
  SLASH_LT = '</'.freeze
  SLASH_GT = ' />'.freeze
  SPACE = ' '.freeze
  MAX_LEVELS = 300
  SPACES = Array.new(MAX_LEVELS) {|i| ('  ' * i).freeze }
  NEWLINE = "\n".freeze
  QUOTE = '"'.freeze
  EQL = '='.freeze
  EQL_QUOTE = EQL + QUOTE
  COMMENT_START = '<!--'.freeze
  COMMENT_END = '-->'.freeze
  CDATA_START = '<![CDATA['.freeze
  CDATA_END = ']]>'.freeze

  module Helper
    def self.included(base)
      super
      base.extend ClassMethods
      base.class_inheritable_array :builder_methods, :instance_writer => false, :instance_reader => false
    end

    module ClassMethods

      # adds instance method to the class. Method accepts any instance of builder and returns it after rendering.
      # @param [Symbol] method_name
      # @yield [self] builder_block is evaluated inside builder and accepts instance of a rendered object as parameter
      # @example
      #   class User
      #   # ...
      #     include HammerBuilder::Helper
      #
      #     builder :menu do |user|
      #       li user.name
      #     end
      #   end
      #
      #   User.new.menu(HammerBuilder::Standard.get).to_xhtml! #=> "<li>Name</li>"
      def builder(method_name, &builder_block)
        self.builder_methods = [method_name.to_sym]
        define_method(method_name) do |builder, *args|
          builder.go_in(self, *args, &builder_block)
        end
      end
    end
  end

  # Creating builder instances is expensive, therefore you can use Pool to go around that
  module Pool
    def self.included(base)
      super
      base.extend ClassMethods
    end
    
    module ClassMethods
      # This the preferred way of getting new Builder. If you forget to release it, it does not matter -
      # builder gets GCed after you lose reference
      # @return [Standard, Formated]
      def get
        mutex.synchronize do
          if free_builders.empty?
            new
          else
            free_builders.pop
          end
        end
      end

      # returns +builder+ back into pool *DONT* forget to lose the reference to the +builder+
      # @param [Standard, Formated]
      def release(builder)
        builder.reset
        mutex.synchronize do
          free_builders.push builder
        end
        nil
      end

      # @return [Fixnum] size of free builders
      def pool_size
        free_builders.size
      end

      private
      
      def mutex
        @mutex ||= Mutex.new
      end

      def free_builders
        @free_builders ||= []
      end
    end

    # instance version of ClassMethods.release
    # @see ClassMethods.release
    def release!
      self.class.release(self)
    end
  end

  # Abstract implementation of Builder
  class Abstract
    extend DynamicClasses
    include Pool

    # << faster then +
    # yield faster then block.call
    # accessing ivar and constant is faster then accesing hash or cvar
    # class_eval faster then define_method
    # beware of strings in methods -> creates a lot of garbage

    dc do

      define :AbstractTag do
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

        # @example
        # div.attributes :id => 'id' # => <div id="id"></div>
        def attributes(attrs)
          return self unless attrs
          attrs.each do |attr, value|
            __send__(attr, *value)
          end
          self
        end

        # @example
        #   div.attribute :id, 'id' # => <div id="id"></div>
        # @deprecated Please use {#attributes} instead
        def attribute(attribute, content) # TODO lose the method in 0.2
          warn ("method #attribute is deprecated use #attributes instead, called from:#{caller[0]}" )
          @output << SPACE << attribute.to_s << EQL_QUOTE << CGI.escapeHTML(content.to_s) << QUOTE
        end

        alias_method(:rclass, :class)

        class_inheritable_array :_attributes, :instance_writer => false, :instance_reader => false

        def self.attributes
          self._attributes
        end

        class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
        # allows data-* attributes
        def method_missing(method, *args, &block)
          if method.to_s =~ /data_([a-z_]+)/
            self.rclass.attributes = [method.to_s]
            self.send method, *args, &block
          else
            super
          end
        end
        RUBYCODE

        protected

        # sets the right tag in descendants
        def self.set_tag(tag)
          class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
          def set_tag
            @tag = '#{tag}'.freeze
          end
          RUBYCODE
        end

        set_tag 'abstract'

        # this method is called on each tag opening, useful for default attributes
        # @example html tag uses this to add xmlns attr.
        #   html # => <html xmlns="http://www.w3.org/1999/xhtml"></html>
        def default
        end

        # defines dynamically methods for attributes
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

        # defines constant strings not to make garbage
        def self.define_attribute_constants
          attributes.each do |attr|
            const = "attr_#{attr}".upcase
            HammerBuilder.const_set const, " #{attr.gsub('_', '-')}=\"".freeze unless HammerBuilder.const_defined?(const)
          end
        end

        # adds attribute to class, triggers dynamical creation of needed instance methods etc.
        def self.attributes=(attributes)
          self._attributes = attributes
          define_attributes
        end

        # flushes classes to output
        def flush_classes
          unless @classes.empty?
            @output << ATTR_CLASS << CGI.escapeHTML(@classes.join(SPACE)) << QUOTE
            @classes.clear
          end
        end

        public

        # global HTML5 attributes
        self.attributes = GLOBAL_ATTRIBUTES

        alias :[] :id

        class_eval <<-RUBYCODE, __FILE__, __LINE__ + 1
        def class(*classes)
          @classes.push(*classes)
          self
        end
        RUBYCODE
      end

      define :AbstractEmptyTag, :AbstractTag do
        def flush
          flush_classes
          @output << SLASH_GT
          nil
        end
      end

      define :AbstractDoubleTag, :AbstractTag do
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

        # sets content of the double tag
        def content(content)
          @content = content.to_s
          self
        end

        # renders content of the double tag with block
        def with
          flush_classes
          @output << GT
          @content = nil
          @builder.current = nil
          yield
          #        if (content = yield).is_a?(String)
          #          @output << CGI.escapeHTML(content)
          #        end
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
    end

    class_inheritable_accessor :tags, :instance_writer => false
    self.tags = {}

    protected

    # defines instance method for +tag+ in builder
    def self.define_tag(tag)
      tag = tag.to_s
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
      # tag classes initialization
      tags.values.each do |klass|
        instance_variable_set(:"@#{klass}", self.class.dc[klass.camelize.to_sym].new(self))
      end
    end

    # escapes +text+ to output
    def text(text)
      flush
      @output << CGI.escapeHTML(text.to_s)
    end

    # unescaped +text+ to output
    def raw(text)
      flush
      @output << text.to_s
    end

    # inserts +comment+
    def comment(comment)
      flush
      @output << COMMENT_START << comment.to_s << COMMENT_END
    end

    # insersts CDATA with +content+
    def cdata(content)
      flush
      @output << CDATA_START << content.to_s << CDATA_END
    end

    def xml_version(version = '1.0', encoding = 'UTF-8')
      flush
      @output << "<?xml version=\"#{version}\" encoding=\"#{encoding}\"?>"
    end

    def doctype
      flush
      @output << "<!DOCTYPE html>"
    end

    # inserts xhtml5 header
    def xhtml5!
      xml_version
      doctype
    end

    # resets the builder to the state after creation - much faster then creating a new one
    def reset
      flush
      @output.clear
      @stack.clear
      self
    end

    # enables you to evaluate +block+ inside the builder with +variables+
    # @example
    #  HammerBuilder::Formated.get.freeze.go_in('asd') do |string|
    #    div string
    #  end.to_html! #=> "<div>asd</div>"
    #
    def go_in(*variables, &block)
      instance_exec *variables, &block
      self
    end

    def set_variables(instance_variables)
      instance_variables.each {|name,value| instance_variable_set("@#{name}", value) }
      yield
      instance_variables.each {|name,_| remove_instance_variable("@#{name}") }
      self
    end

    # @return [String] output
    def to_xhtml()
      flush
      @output.clone
    end

    # @return [String] output and releases the builder to pool
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

  # Builder implementation without formating (one line)
  class Standard < Abstract

    dc do
      (DOUBLE_TAGS - ['html']).each do |tag|
        define tag.camelize.to_sym , :AbstractDoubleTag do
          set_tag tag
          self.attributes = EXTRA_ATTRIBUTES[tag]
        end

        base.define_tag(tag)
      end

      define :Html, :AbstractDoubleTag do
        set_tag 'html'
        self.attributes = ['xmlns'] + EXTRA_ATTRIBUTES['html']

        def default
          xmlns('http://www.w3.org/1999/xhtml')
        end
      end
      base.define_tag('html')

      EMPTY_TAGS.each do |tag|
        define tag.camelize.to_sym, :AbstractEmptyTag do
          set_tag tag
          self.attributes = EXTRA_ATTRIBUTES[tag]
        end

        base.define_tag(tag)
      end
    end

    def js(js , options = {})
      flush
      script({:type => "text/javascript"}.merge(options)) { cdata js }
    end

    def join(collection, glue, &it)
      flush
      glue_block = if glue.is_a? String
        lambda { text glue }
      else
        glue
      end
      
      collection.each_with_index do |obj, i|
        glue_block.call() if i > 0
        it.call(obj)        
      end
    end

  end

  # Builder implementation with formating (indented by '  ')
  # Slow down is less then 1%
  class Formated < Standard

    dc do
      extend :AbstractTag do
        def open(attributes = nil)
          @output << NEWLINE << SPACES.fetch(@stack.size, SPACE) << LT << @tag
          @builder.current = self
          attributes(attributes)
          default
          self
        end
      end

      extend :AbstractDoubleTag do
        def with
          flush_classes
          @output << GT
          @content = nil
          @builder.current = nil
          yield
          #        if (content = yield).is_a?(String)
          #          @output << CGI.escapeHTML(content)
          #        end
          @builder.flush
          @output << NEWLINE << SPACES.fetch(@stack.size-1, SPACE) << SLASH_LT << @stack.pop << GT
          nil
        end
      end
    end

    def comment(comment)
      @output << NEWLINE << SPACES.fetch(@stack.size, SPACE) << COMMENT_START << comment.to_s << COMMENT_END
    end
  end
end

