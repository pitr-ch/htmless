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

