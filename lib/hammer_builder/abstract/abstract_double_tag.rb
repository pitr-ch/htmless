module HammerBuilder
  class Abstract
    dynamic_classes do

      def_class :AbstractDoubleTag, :AbstractTag do ###import
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
                self.rclass.add_attributes Data::Attribute.new(method.to_sym, :string)
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
            @stack << @tag_name
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
          @output << Strings::GT
          @output << CGI.escapeHTML(@content) if @content
          @output << Strings::SLASH_LT << @stack.pop << Strings::GT
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
          @output << Strings::GT
          @content         = nil
          @builder.current = nil
          yield
          #if (content = yield).is_a?(String)
          #  @output << EscapeUtils.escape_html(content)
          #end
          @builder.flush
          @output << Strings::SLASH_LT << @stack.pop << Strings::GT
          nil
        end

        alias_method :w, :with

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def mimic(obj, &block)
            super(obj, &nil)
            return with(&block) if block
            self
          end

          def data(hash, &block)
            super(hash, &nil)
            return with(&block) if block
            self
          end

          def attribute(name, value, &block)
            super(name, value, &nil)
            return with(&block) if block
            self
          end

          def attributes(attrs, &block)
            super(attrs, &nil)
            return with(&block) if block
            self
          end
        RUBY

        protected

        # @api private
        def self.define_attribute_method(attribute)
          return if instance_methods(false).include?(attribute.name)
          name = attribute.name.to_s

          if instance_methods.include?(attribute.name)
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(*args, &block)
            super(*args, &nil)
            return with(&block) if block
            self
          end
            RUBY
          else
            content_rendering = attribute_content_rendering(attribute)
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(content#{' = true' if attribute.type == :boolean}, &block)
            #{content_rendering}
            return with(&block) if block
            self
          end
            RUBY
          end
        end
      end ###import
    end
  end
end
