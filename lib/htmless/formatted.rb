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

require 'htmless/standard'

module Htmless
  # Builder implementation with formatting (indented by '  ')
  # Slow down is less then 1%
  class Formatted < Standard

    dynamic_classes do
      extend_class :AbstractTag do
        def open(attributes = nil)
          @output << @_str_newline << @_str_spaces.fetch(@stack.size, @_str_space) << @_str_lt << @tag_name
          @builder.current = self
          attributes(attributes)
          default
          self
        end
      end

      extend_class :AbstractDoubleTag do
        def with
          flush_classes
          @output << @_str_gt
          @content         = nil
          @builder.current = nil
          yield
          #if (content = yield).is_a?(String)
          #  @output << EscapeUtils.escape_html(content, false)
          #end
          @builder.flush
          @output << @_str_newline << @_str_spaces.fetch(@stack.size-1, @_str_space) << @_str_slash_lt <<
              @stack.pop << @_str_gt
          nil
        end
      end
    end

    def comment(comment)
      flush
      @_output << @_str_newline << @_str_spaces.fetch(@_stack.size, @_str_space) << @_str_comment_start <<
          comment.to_s << @_str_comment_end
    end
  end
end
