module HammerBuilder
  class Abstract
    dynamic_classes do
      define :AbstractSingleTag, :AbstractTag do ###import
        nil

        # @api private
        # closes the tag
        def flush
          flush_classes
          @output << Strings::SLASH_GT
          nil
        end
      end ###import
    end
  end
end

