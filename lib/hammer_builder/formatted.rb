module HammerBuilder
  # Builder implementation with formatting (indented by '  ')
  # Slow down is less then 1%
  class Formatted < Standard

    dynamic_classes do
      extend :AbstractTag do
        def open(attributes = nil)
          @output << Strings::NEWLINE << Strings::SPACES.fetch(@stack.size, Strings::SPACE) << Strings::LT << @tag_name
          @builder.current = self
          attributes(attributes)
          default
          self
        end
      end

      extend :AbstractDoubleTag do
        def with
          flush_classes
          @output << Strings::GT
          @content         = nil
          @builder.current = nil
          yield
          #if (content = yield).is_a?(String)
          #  @output << EscapeUtils.escape_html(content, false)
          #end
          @builder.flush
          @output << Strings::NEWLINE << Strings::SPACES.fetch(@stack.size-1, Strings::SPACE) << Strings::SLASH_LT <<
              @stack.pop << Strings::GT
          nil
        end
      end
    end

    def comment(comment)
      flush
      @_output << Strings::NEWLINE << Strings::SPACES.fetch(@_stack.size, Strings::SPACE) << Strings::COMMENT_START <<
          comment.to_s << Strings::COMMENT_END
    end
  end
end
