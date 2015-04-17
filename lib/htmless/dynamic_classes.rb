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

# When extended into a class it enables easy defining and extending classes in the class.
#
#   class A
#     extend DynamicClasses
#     dynamic_classes do
#       def_class :A do
#         def to_s
#           'a'
#         end
#       end
#       def_class :B, :A do
#         class_eval <<-RUBYCODE, __FILE__, __LINE__+1
#           def to_s
#             super + 'b'
#           end
#         RUBYCODE
#       end
#     end
#   end
#
#   class B < A
#   end
#
#   class C < A
#     dynamic_classes do
#       extend_class :A do
#         def to_s
#           'aa'
#         end
#       end
#     end
#   end
#
#   puts A.dc[:A] # => #<Class:0x00000001d449b8(A.dc[:A])>
#   puts B.dc[:A] # => #<Class:0x00000001d42398(B.dc[:A])>
#   puts B.dc[:A].new # => a
#   puts B.dc[:B].new # => ab
#   puts C.dc[:B].new # => aab
#
# Last example is the most interesting. It prints 'aab' not 'ab' because of the extension in class C. Class :B has
# as ancestor extended class :A from C therefore the two 'a'.
  module DynamicClasses

    # Adds ability to describe itself when class is defined without constant
    module Describable
      def self.included(base)
        base.singleton_class.send :alias_method, :original_to_s, :to_s
        base.extend ClassMethods
      end

      module ClassMethods
        # sets +description+
        # @param [String] description
        def _description=(description)
          @_description = description
        end

        def to_s
          super.gsub(/>$/, "(#{@_description})>")
        end
      end

      def to_s
        klass = respond_to?(:rclass) ? self.rclass : self.class
        super.gsub(klass.original_to_s, klass.to_s)
      end
    end

    class DescribableClass
      include Describable
    end

    ClassDefinition = Struct.new(:name, :base, :superclass_or_name, :definition)
    ClassExtension  = Struct.new(:name, :base, :definition)

    class Classes
      attr_reader :base, :class_definitions, :classes, :class_extensions

      def initialize(base)
        raise unless base.is_a? Class
        @base              = base
        @class_definitions = { }
        @class_extensions  = { }
        @classes           = { }
      end

      # define a class
      # @param [Symbol] name
      # @param [Symbol, Class, nil] superclass_or_name
      # when Symbol then dynamic class is found
      # when Class then this class is used
      # when nil then Object is used
      # @yield definition block is evaluated inside the class defining it
      def def_class(name, superclass_or_name = nil, &definition)
        raise ArgumentError, "name is not a Symbol" unless name.is_a?(Symbol)
        unless superclass_or_name.is_a?(Symbol) || superclass_or_name.is_a?(Class) || superclass_or_name.nil?
          raise ArgumentError, "superclass_or_name is not a Symbol, Class or nil"
        end
        raise ArgumentError, "definition is nil" unless definition
        raise ArgumentError, "Class #{name} already defined" if class_definition(name)
        @class_definitions[name] = ClassDefinition.new(name, base, superclass_or_name, definition)
      end

      # extends already defined class by adding a child,
      # @param [Symbol] name
      # @yield definition block is evaluated inside the class extending it
      def extend_class(name, &definition)
        raise ArgumentError, "name is not a Symbol" unless name.is_a?(Symbol)
        raise ArgumentError, "definition is nil" unless definition
        raise ArgumentError, "Class #{name} not defined" unless class_definition(name)
        @class_extensions[name] = ClassExtension.new(name, base, definition)
      end

      # triggers loading of all defined classes
      def load!
        class_names.each { |name| self[name] }
      end

      # @return [Class] defined class
      def [](name)
        return @classes[name] if @classes[name]
        return nil unless klass_definition = class_definition(name)

        superclass = case klass_definition.superclass_or_name
                       when Symbol then
                         self[klass_definition.superclass_or_name]
                       when Class then
                         klass = Class.new(klass_definition.superclass_or_name)
                         klass.send :include, Describable
                         klass._description = "Describable#{klass_definition.superclass_or_name}"
                         klass
                       when nil then
                         DescribableClass
                     end

        set_up_klass = lambda do |klass, description, block|
          klass._description = description
          klass.instance_variable_set :@dynamic_class_base, base
          klass.singleton_class.send :attr_reader, :dynamic_class_base
          klass.class_eval &block
        end

        klass = Class.new(superclass)
        set_up_klass.call klass, "#{base}.dc[:#{klass_definition.name}]", klass_definition.definition

        class_extensions(name).each do |klass_extension|
          klass = Class.new klass
          set_up_klass.call klass, "#{base}.dc[:#{klass_extension.name}]", klass_extension.definition
        end

        @classes[name] = klass
      end

      def class_names
        ancestors.map(&:class_definitions).map(&:keys).flatten
      end

      private

      def class_definition(name)
        @class_definitions[name] or (ancestor.send :class_definition, name if ancestor)
      end

      def class_extensions(name)
        ([*(ancestor.send :class_extensions, name if ancestor)] + [@class_extensions[name]]).compact
      end

      def ancestors
        ([self] + [*(ancestor.ancestors if ancestor)]).compact
      end

      def ancestor
        @base.superclass.dynamic_classes if @base.superclass.kind_of?(DynamicClasses)
      end
    end

    # hook to create Classes instance
    def self.extended(base)
      base.send :create_dynamic_classes
      super
    end

    # hook to create Classes instance in descendants
    def inherited(base)
      base.send :create_dynamic_classes
      super
    end

    # call this to get access to Classes instance to define/extend classes inside +definition+
    # calls Classes#load! to preload defined classes
    # @yield [Proc, nil] definition
    # a Proc enables writing class definitions/extensions
    # @return [Classes] when definition is nil
    def dynamic_classes(&definition)
      if definition
        @dynamic_classes.instance_eval &definition
        # @dynamic_classes.load!
        nil
      else
        @dynamic_classes
      end
    end

    alias_method :dc, :dynamic_classes

    private

    def create_dynamic_classes
      @dynamic_classes = Classes.new(self)
    end
  end
end


