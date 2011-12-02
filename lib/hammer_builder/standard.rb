require 'hammer_builder/abstract'

module HammerBuilder

  # Builder implementation without formating (one line output)
  class Standard < Abstract

    dynamic_classes do
      extend :AbstractTag do
        # add global HTML5 attributes
        self.add_attributes Data::HTML5.abstract_attributes
      end

      Data::HTML5.double_tags.each do |tag|
        next if tag.name == :html

        define tag.name.to_s.camelize.to_sym, :AbstractDoubleTag do
          set_tag tag.name
          self.add_attributes tag.attributes
        end

        base.define_tag(tag.name)
      end

      html_tag = Data::HTML5.double_tags.find { |t| t.name == :html }
      define :Html, :AbstractDoubleTag do
        set_tag html_tag.name
        self.add_attributes [Data::Attribute.new(:xmlns, :string)] + html_tag.attributes

        def default
          xmlns('http://www.w3.org/1999/xhtml')
        end
      end
      base.define_tag(html_tag.name)

      Data::HTML5.single_tags.each do |tag|
        define tag.name.to_s.camelize.to_sym, :AbstractSingleTag do
          set_tag tag.name
          self.add_attributes tag.attributes
        end

        base.define_tag(tag.name)
      end
    end

  end
end

