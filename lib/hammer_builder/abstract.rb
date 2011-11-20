module HammerBuilder

# Abstract implementation of Builder
  class Abstract
    extend DynamicClasses

    # << faster then +
    # yield faster then block.call
    # accessing ivar and constant is faster then accesing hash or cvar
    # class_eval faster then define_method
    # beware of strings in methods -> creates a lot of garbage

    dynamic_classes do
      define :AbstractTag do ###import

        class_attribute :_attributes, :instance_writer => false, :instance_reader => false
        self._attributes = []

        # @return [Array<String>] array of available attributes for the tag
        def self.attributes
          self._attributes
        end

        protected

        # sets the right tag in descendants
        # @api private
        def self.set_tag(tag)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def set_tag
              @tag = '#{tag}'.freeze
            end
          RUBY
        end

        set_tag 'abstract'

        # defines dynamically methods for attributes
        # @api private
        def self.define_attributes
          attributes.each do |attr|
            next if instance_methods.include?(attr.to_sym)
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{attr}(content)
                @output << ATTR_#{attr.upcase} << CGI.escapeHTML(content.to_s) << QUOTE
                self
              end
            RUBY
          end
          define_attribute_constants
        end

        # defines constant strings not to make garbage
        # @api private
        def self.define_attribute_constants
          attributes.each do |attr|
            const = "attr_#{attr}".upcase
            unless HammerBuilder.const_defined?(const)
              HammerBuilder.const_set const, " #{attr.gsub('_', '-')}=\"".freeze # TODO define in attribute class
            end
          end
        end

        # adds attribute to class, triggers dynamical creation of needed instance methods etc.
        # @param [Array<String>] attributes
        # @api private
        def self.add_attributes(attributes)
          self._attributes += [*attributes]
          define_attributes
        end

        # add global HTML5 attributes
        self.add_attributes GLOBAL_ATTRIBUTES

        public

        attr_reader :builder

        # @api private
        def initialize(builder)
          @builder = builder
          @output  = builder.instance_eval { @_output }
          @stack   = builder.instance_eval { @_stack }
          @classes = []
          set_tag
        end

        # @api private
        def open(attributes = nil)
          @output << LT << @tag
          @builder.current = self
          attributes(attributes)
          default
          self
        end

        # @example
        #   div.attributes :id => 'id' # => <div id="id"></div>
        #   div :id => 'id', :class => %w{left right} # => <div id="id" class="left right"></div>
        #   img :src => 'path' # => <img src="path"></div>
        # attribute`s methods are called on background (in this case #id is called)
        def attributes(attrs)
          return self unless attrs
          attrs.each do |attr, value|
            __send__(attr, *(value ? value : [nil]))
          end
          self
        end

        # original Ruby method for class, class is used for html classes
        alias_method(:rclass, :class)

        id_class       = /^([\w]+)(!|)$/
        data_attribute = /^data_([a-z_]+)$/
        METHOD_MISSING_REGEXP = /#{data_attribute}|#{id_class}/ unless defined? METHOD_MISSING_REGEXP

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # allows data-* attributes and id, classes by method_missing
          def method_missing(method, *args, &block)
            method = method.to_s
            if method =~ METHOD_MISSING_REGEXP
              if $1
                self.rclass.add_attributes method
                self.send method, *args
              else
                self.__send__($3 == '!' ? :id : :class, $2)
              end
            else
              super(method, *args, &block)
            end
          end

          def respond_to?(symbol, include_private = false)
            symbol.to_s =~ METHOD_MISSING_REGEXP || super(symbol, include_private)
          end
        RUBY

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def class(*classes)
            @classes.push(*classes)
            self
          end
        RUBY

        protected

        # this method is called on each tag opening, useful for default attributes
        # @example html tag uses this to add xmlns attr.
        #   html # => <html xmlns="http://www.w3.org/1999/xhtml"></html>
        def default
        end

        # flushes classes to output
        # @api private
        def flush_classes
          unless @classes.empty?
            @output << ATTR_CLASS << CGI.escapeHTML(@classes.join(SPACE)) << QUOTE
            @classes.clear
          end
        end
      end ###import

      define :AbstractEmptyTag, :AbstractTag do ###import
        nil

        # @api private
        # closes the tag
        def flush
          flush_classes
          @output << SLASH_GT
          nil
        end
      end ###import

      define :AbstractDoubleTag, :AbstractTag do ###import
        nil

        # defined by class_eval because there is a error cased by super
        # super from singleton method that is defined to multiple classes is not supported;
        # this will be fixed in 1.9.3 or later (NotImplementedError)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # @api private
          def initialize(builder)
            super
            @content = nil
          end

          # allows data-* attributes and id, classes by method_missing
          def method_missing(method, *args, &block)
            method = method.to_s
            if method =~ METHOD_MISSING_REGEXP
              if $1
                self.rclass.add_attributes method
                self.send method, *args, &block
              else
                self.content(args[0]) if args[0]
                self.__send__($3 == '!' ? :id : :class, $2, &block)
              end
            else
              super(method, *args, &block)
            end
          end

          # @api private
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
        RUBY

        # @api private
        # closes the tag
        def flush
          flush_classes
          @output << GT
          @output << CGI.escapeHTML(@content) if @content
          @output << SLASH_LT << @stack.pop << GT
          @content = nil
        end

        # sets content of the double tag
        # @example
        #   div 'content' # => <div>content</div>
        #   div.content 'content' # => <div>content</div>
        #   div :content => 'content' # => <div>content</div>
        def content(content)
          @content = content.to_s
          self
        end

        # renders content of the double tag with block
        # @yield content of the tag
        # @example
        #   div { text 'content' } # => <div>content</div>
        #   div :id => 'id' do
        #     text 'content'
        #   end # => <div id="id">content</div>
        def with
          flush_classes
          @output << GT
          @content         = nil
          @builder.current = nil
          yield
          #if (content = yield).is_a?(String)
          #  @output << EscapeUtils.escape_html(content)
          #end
          @builder.flush
          @output << SLASH_LT << @stack.pop << GT
          nil
        end

        protected

        # @api private
        def self.define_attributes
          attributes.each do |attr|
            next if instance_methods(false).include?(attr.to_sym)
            if instance_methods.include?(attr.to_sym)
              class_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{attr}(*args, &block)
                  super(*args, &nil)
                  return with(&block) if block
                  self
                end
              RUBY
            else
              class_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{attr}(content, &block)
                  @output << ATTR_#{attr.upcase} << CGI.escapeHTML(content.to_s) << QUOTE
                  return with(&block) if block
                  self
                end
              RUBY
            end
          end
          define_attribute_constants
        end
      end ###import
    end

    class_attribute :tags, :instance_writer => false
    self.tags = []

    protected

    # defines instance method for +tag+ in builder
    def self.define_tag(tag)
      tag = tag.to_s
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{tag}(*args, &block)
          flush
          @_#{tag}.open(*args, &block)
        end
      RUBY
      self.tags += [tag]
    end

    public

    # current tag being builded
    attr_accessor :_current
    alias :current :_current
    alias :current= :_current=

    # creates a new builder
    # This is quite expensive, HammerBuilder::Pool should be used
    def initialize()
      @_output  = ""
      @_stack   = []
      @_current = nil
      # tag classes initialization
      tags.each do |klass|
        instance_variable_set(:"@_#{klass}", self.class.dynamic_classes[klass.camelize.to_sym].new(self))
      end
    end

    # escapes +text+ to output
    def text(text)
      flush
      @_output << CGI.escapeHTML(text.to_s)
    end

    # unescaped +text+ to output
    def raw(text)
      flush
      @_output << text.to_s
    end

    # inserts +comment+
    def comment(comment)
      flush
      @_output << COMMENT_START << comment.to_s << COMMENT_END
    end

    # insersts CDATA with +content+
    def cdata(content)
      flush
      @_output << CDATA_START << content.to_s << CDATA_END
    end

    # renders xml version
    # @example
    #   xml_version # => <?xml version="1.0" encoding="UTF-8"?>
    def xml_version(version = '1.0', encoding = 'UTF-8')
      flush
      @_output << "<?xml version=\"#{version}\" encoding=\"#{encoding}\"?>\n"
    end

    # renders html5 doc type
    # @example
    #   doctype # => <!DOCTYPE html>
    def doctype
      flush
      @_output << "<!DOCTYPE html>\n"
    end

    # inserts xhtml5 header
    def xhtml5!
      xml_version
      doctype
    end

    # resets the builder to the state after creation - much faster then creating a new one
    def reset
      flush
      @_output.clear
      @_stack.clear
      self
    end

    #def capture
    #  flush
    #  _output = @_output.clone
    #  _stack  = @_stack.clone
    #  @_output.clear
    #  @_stack.clear
    #  yield
    #  to_xhtml
    #ensure
    #  @_output.replace _output
    #  @_stack.replace _stack
    #end

    # enables you to evaluate +block+ inside the builder with +variables+
    # @example
    #  HammerBuilder::Formatted.new.go_in('asd') do |string|
    #    div string
    #  end.to_html! #=> "<div>asd</div>"
    #
    def go_in(*variables, &block)
      instance_exec *variables, &block
      self
    end

    alias_method :dive, :go_in

    # sets instance variables when block is yielded
    # @param [Hash{String => Object}] instance_variables hash of names and values to set
    # @yield block when variables are set, variables are cleaned up afterwards
    def set_variables(instance_variables)
      instance_variables.each { |name, value| instance_variable_set("@#{name}", value) }
      yield(self)
      instance_variables.each { |name, _| remove_instance_variable("@#{name}") }
      self
    end

    # @return [String] output
    def to_xhtml()
      flush
      @_output.clone
    end

    # flushes open tag
    # @api private
    def flush
      if @_current
        @_current.flush
        @_current = nil
      end
    end

    # renders +object+ with +method+
    # @param [Object] object an object to render
    # @param [Symbol] method a method name which is used for rendering
    # @param args arguments passed to rendering method
    # @yield block passed to rendering method
    def render(object, method, *args, &block)
      object.__send__ method, self, *args, &block
    end

    # renders js
    # @option options [Boolean] :cdata (false) should cdata be used?
    # @example
    #   js 'a_js_function();' #=> <script type="text/javascript">a_js_function();</script>
    def js(js, options = { })
      use_cdata = options.delete(:cdata) || false
      script({ :type => "text/javascript" }.merge(options)) { use_cdata ? cdata(js) : text(js) }
    end

    # joins and renders +collection+ with +glue+
    # @param [Array<Proc, Object>] collection of objects or lambdas
    # @param [Proc, String] glue can be String which is rendered with #text or block to render
    # @yield how to render objects from +collection+, Proc in collection does not use this block
    # @example
    #   join([1, 1.2], lambda { text ', ' }) {|o| text o }        # => "1, 1.2"
    #   join([1, 1.2], ', ') {|o| text o }                        # => "1, 1.2"
    #   join([->{ text 1 }, 1.2], ', ') {|o| text o }             # => "1, 1.2"
    def join(collection, glue = nil, &it)
      # TODO as helper? two block method call #join(collection, &item).with(&glue)
      glue_block = case glue
        when String
          lambda { text glue }
        when Proc
          glue
        else
          lambda { }
      end

      collection.each_with_index do |obj, i|
        glue_block.call() if i > 0
        obj.is_a?(Proc) ? obj.call : it.call(obj)
      end
    end


  end
end
