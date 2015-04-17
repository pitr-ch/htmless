# Htmless
# Copyright (C) 2015 Petr Chalupa <git@pitr.ch>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA

module Htmless
  class Abstract
    dynamic_classes do

      def_class :AbstractDoubleTag, :AbstractTag do ###import
        nil

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
          @stack << @tag_name
          if block
            with &block
          else
            self
          end
        end

        # @api private
        # closes the tag
        def flush
          flush_classes
          @output << @_str_gt
          @output << CGI.escapeHTML(@content) if @content
          @output << @_str_slash_lt << @stack.pop << @_str_gt
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
          @output << @_str_gt
          @content = nil
          @builder.current = nil
          yield
          #if (content = yield).is_a?(String)
          #  @output << EscapeUtils.escape_html(content)
          #end
          @builder.flush
          @output << @_str_slash_lt << @stack.pop << @_str_gt
          nil
        end

        alias_method :w, :with

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
