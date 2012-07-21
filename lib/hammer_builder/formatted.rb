require 'hammer_builder/standard'

module HammerBuilder
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
