module HammerBuilder
  module Helper
    def self.included(base)
      super
      base.extend ClassMethods
      base.class_attribute :builder_methods, :instance_writer => false, :instance_reader => false
      base.builder_methods = []
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
        self.builder_methods += [method_name.to_sym]
        define_method(method_name) do |builder, *args|
          builder.go_in(self, *args, &builder_block)
        end
      end
    end
  end
end
