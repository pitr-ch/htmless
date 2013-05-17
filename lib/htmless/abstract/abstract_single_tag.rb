module Htmless
  class Abstract
    dynamic_classes do
      def_class :AbstractSingleTag, :AbstractTag do ###import
        nil

        # @api private
        # closes the tag
        def flush
          flush_classes
          @output << @_str_slash_gt
          nil
        end
      end ###import
    end
  end
end

