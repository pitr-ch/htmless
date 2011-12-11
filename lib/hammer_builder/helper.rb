module HammerBuilder
  module Helper

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
    #   User.new.menu(HammerBuilder::Standard.get).to_html! #=> "<li>Name</li>"
    def builder(method_name, &builder_block)
      define_method(method_name) do |builder, *args|
        builder.dive(self, *args, &builder_block)
      end
    end
  end
end
