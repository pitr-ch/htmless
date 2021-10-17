module Htmless
  class Abstract
    dynamic_classes do
      def_class :AbstractTag do ###import

        def self.strings_injector
          dynamic_class_base.strings_injector
        end

        def self._attributes=(_attributes)
          @_attributes = _attributes
        end

        def self._attributes
          @_attributes or (superclass._attributes if superclass.respond_to? :_attributes)
        end

        self._attributes = []

        # @return [Array<String>] array of available attributes for the tag
        def self.attributes
          _attributes
        end

        # @return [String] tag's name
        def self.tag_name
          @tag || superclass.tag_name
        end

        protected

        # sets the tag's name
        # @api private
        def self.set_tag(tag)
          @tag = tag.to_s.freeze
        end

        set_tag 'abstract'

        # defines dynamically methods for attributes
        # @api private
        def self.define_attribute_methods
          attributes.each { |attr| define_attribute_method(attr) }
        end

        def self.inherited(base)
          base.define_attribute_methods
        end

        # defines dynamically method for +attribute+
        # @param [Data::Attribute] attribute
        # @api private
        def self.define_attribute_method(attribute)
          return if instance_methods.include?(attribute.name)
          name = attribute.name.to_s
          content_rendering = attribute_content_rendering(attribute)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}(content#{' = true' if attribute.type == :boolean})
              #{content_rendering}
              self
            end
          RUBY
        end

        # @api private
        # @param [Data::Attribute] attribute
        # @returns Ruby code as string
        def self.attribute_content_rendering(attribute)
          name = attribute.name.to_s
          case attribute.type
          when :string
            strings_injector.add "attr_#{name}", " #{name.gsub('_', '-')}=#{strings_injector[:quote]}"
            "@output << @_str_attr_#{name} << CGI.escapeHTML(content.to_s) << @_str_quote"
          when :boolean
            strings_injector.add(
              "attr_#{name}",
              " #{name.gsub('_', '-')}=#{strings_injector[:quote]}#{name}#{strings_injector[:quote]}")
            "@output << @_str_attr_#{name} if content"
          end
        end

        # adds attribute to class, triggers dynamical creation of needed instance methods etc.
        # @param [Array<Data::Attribute>] attributes
        # @api private
        def self.add_attributes(attributes)
          attributes = [attributes] unless attributes.is_a? Array
          raise ArgumentError, attributes.inspect unless attributes.all? { |v| v.is_a? Data::Attribute }
          self.send :_attributes=, _attributes + attributes
          define_attribute_methods
        end

        public

        attr_reader :builder

        # @api private
        def initialize(builder)
          @builder = builder
          @output = builder.instance_eval { @_output }
          @stack = builder.instance_eval { @_stack }
          @classes = []
          @tag_name = self.rclass.tag_name

          self.rclass.strings_injector.inject_to self
        end

        # @api private
        def open(attributes = nil)
          @output << @_str_lt << @tag_name
          @builder.current = self
          attributes(attributes)
          default
          self
        end

        # it renders attribute using defined attribute method or by rendering attribute directly
        # @param [String, Symbol] name
        # @param [#to_s] value
        def attribute(name, value)
          return __send__(name, value) if respond_to?(name)
          @output << @_str_space << name.to_s.gsub('_', '-') << @_str_eql_quote << CGI.escapeHTML(value.to_s) << @_str_quote
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
            if value.kind_of?(Array)
              __send__(attr, *value)
            else
              attribute(attr, value)
            end
          end
          self
        end

        # renaming original object methods
        alias_method :rclass, :class
        undef_method :class
        alias_method :rmethod, :method
        undef_method :method

        data_attribute = /^data_([a-z_]+)$/
        aria_attribute = /^aria_([a-z_]+)$/
        METHOD_MISSING_REGEXP = /#{data_attribute}|#{aria_attribute}/ unless defined? METHOD_MISSING_REGEXP

        # allows data-* attributes method_missing
        def method_missing(method, *args, &block)
          if method.to_s =~ METHOD_MISSING_REGEXP
            raise ArgumentError, "attributes do not take blocks" if block
            self.rclass.add_attributes Data::Attribute.new(method, :string)
            self.__send__ method, *args
          else
            super(method, *args, &block)
          end
        end

        #def respond_to?(symbol, include_private = false)
        #  symbol.to_s =~ METHOD_MISSING_REGEXP || super(symbol, include_private)
        #end

        strings_injector.add "attr_class", " class=#{strings_injector[:quote]}"
        # adds classes to the tag by joining +classes+ with ' ' and skipping non-true classes
        # @param [Array<#to_s>] classes
        # @example
        #   class(!visible? && 'hidden', 'left') #=> class="hidden left" or class="left"
        def class(*classes)
          @classes.push(*classes.select { |c| c })
          self
        end

        strings_injector.add "attr_id", " id=#{strings_injector[:quote]}"
        # adds id to the tag by joining +values+ with '_'
        # @param [Array<#to_s>] values
        # @example
        #   id('user', 12) #=> id="user-15"
        def id(*values)
          @output << @_str_attr_id << CGI.escapeHTML(values.select { |v| v }.join(@_str_dash)) << @_str_quote
          self
        end

        # adds id and class to a tag by an object
        # @param [Object] obj
        # To determine the class it looks for .htmless_ref or
        # it uses class.to_s.underscore.tr('/', '-').
        # To determine id it looks for #htmless_ref or it takes class and #id or #object_id.
        # @example
        #   div[AUser.new].with { text 'a' } # => <div id="a_user_1" class="a_user">a</div>
        def mimic(obj)
          klass = if obj.class.respond_to? :htmless_ref
                    obj.class.htmless_ref
                  else
                    obj.class.to_s.scan(/[A-Z][a-z\d]*/).join('_').downcase.gsub('::', '-')
                  end

          id = case
               when obj.respond_to?(:htmless_ref)
                 obj.htmless_ref
               when obj.respond_to?(:id)
                 [klass, obj.id]
               else
                 [klass, obj.object_id]
               end
          #noinspection RubyArgCount
          self.class(klass).id(id)
        end

        alias_method :[], :mimic

        # renders data-* attributes by +hash+
        # @param [Hash] hash
        # @example
        #   div.data(:remote => true, :id => 'an_id') # => <div data-remote="true" data-id="an_id"></div>
        def data(hash)
          hash.each { |k, v| __send__ "data_#{k}", v }
          self
        end

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
            @output << @_str_attr_class << CGI.escapeHTML(@classes.join(@_str_space)) << @_str_quote
            @classes.clear
          end
        end
      end ###import

    end
  end
end
