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
