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

require 'htmless/abstract'

module Htmless

  # Builder implementation without formating (one line output)
  class Standard < Abstract

    dynamic_classes do
      extend_class :AbstractTag do
        # add global HTML5 attributes
        self.add_attributes Data::HTML5.abstract_attributes
      end

      Data::HTML5.double_tags.each do |tag|
        next if tag.name == :html

        def_class Abstract.camelize_string(tag.name.to_s).to_sym, :AbstractDoubleTag do
          set_tag tag.name
          self.add_attributes tag.attributes
        end

        base.define_tag(tag.name)
      end

      html_tag = Data::HTML5.double_tags.find { |t| t.name == :html }
      def_class :Html, :AbstractDoubleTag do
        set_tag html_tag.name
        self.add_attributes html_tag.attributes

        def default
          attribute :xmlns ,'http://www.w3.org/1999/xhtml'
        end
      end
      base.define_tag(html_tag.name)

      Data::HTML5.single_tags.each do |tag|
        def_class Abstract.camelize_string(tag.name.to_s).to_sym, :AbstractSingleTag do
          set_tag tag.name
          self.add_attributes tag.attributes
        end

        base.define_tag(tag.name)
      end
    end

  end
end

