module HammerBuilder

  # Builder implementation without formating (one line output)
  class Standard < Abstract

    dynamic_classes do
      (DOUBLE_TAGS - ['html']).each do |tag|
        define tag.camelize.to_sym, :AbstractDoubleTag do
          set_tag tag
          self.attributes = EXTRA_ATTRIBUTES[tag]
        end

        base.define_tag(tag)
      end

      define :Html, :AbstractDoubleTag do
        set_tag 'html'
        self.attributes = ['xmlns'] + EXTRA_ATTRIBUTES['html']

        def default
          xmlns('http://www.w3.org/1999/xhtml')
        end
      end
      base.define_tag('html')

      EMPTY_TAGS.each do |tag|
        define tag.camelize.to_sym, :AbstractEmptyTag do
          set_tag tag
          self.attributes = EXTRA_ATTRIBUTES[tag]
        end

        base.define_tag(tag)
      end
    end

  end
end

