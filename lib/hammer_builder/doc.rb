module HammerBuilder
  module StubBuilderForDocumentation
    class AbstractTag

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

        class_inheritable_array :_attributes, :instance_writer => false, :instance_reader => false

        # @return [Array<String>] array of available attributes for the tag
        def self.attributes
          self._attributes
        end

        ID_CLASS_REGEXP       = /^([\w]+)(!|)$/
        DATA_ATTRIBUTE_REGEXP = /^data_([a-z_]+)$/
        METHOD_MISSING_REGEXP = /#{ID_CLASS_REGEXP}|#{DATA_ATTRIBUTE_REGEXP}/

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # allows data-* attributes and id, classes by method_missing
          def method_missing(method, *args, &block)
            method = method.to_s
            if method =~ METHOD_MISSING_REGEXP
              if $3
                self.rclass.attributes = [method]
                self.send method, *args, &block
              else
                self.content(args[0]) if respond_to?(:content) && args[0]
                self.__send__($2 == '!' ? :id : :class, $1, &block)
              end
            else
              super(method, *args, &block)
            end
          end

          def respond_to?(symbol, include_private = false)
            symbol.to_s =~ METHOD_MISSING_REGEXP || super(symbol, include_private)
          end
        RUBY

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

        # this method is called on each tag opening, useful for default attributes
        # @example html tag uses this to add xmlns attr.
        #   html # => <html xmlns="http://www.w3.org/1999/xhtml"></html>
        def default
        end

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
        # @api private
        def self.attributes=(attributes)
          self._attributes = attributes
          define_attributes
        end

        # flushes classes to output
        # @api private
        def flush_classes
          unless @classes.empty?
            @output << ATTR_CLASS << CGI.escapeHTML(@classes.join(SPACE)) << QUOTE
            @classes.clear
          end
        end

        public

        # add global HTML5 attributes
        self.attributes = GLOBAL_ATTRIBUTES

        alias :[] :id

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def class(*classes)
            @classes.push(*classes)
            self
          end
        RUBY

          end
    class AbstractSingleTag < AbstractTag

        nil

        # @api private
        # closes the tag
        def flush
          flush_classes
          @output << SLASH_GT
          nil
        end
          end
    class AbstractDoubleTag < AbstractTag

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
        # @yieldreturn if String is returned, it's renderend with text
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
          end
  end
end
