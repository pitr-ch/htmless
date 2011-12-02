require 'cgi'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

require 'hammer_builder/dynamic_classes'
require 'hammer_builder/strings'
require 'hammer_builder/data'
require 'hammer_builder/data/html5'
require "hammer_builder/pool"
require "hammer_builder/helper"

module HammerBuilder

# Abstract implementation of Builder
  class Abstract
    extend DynamicClasses

    require "hammer_builder/abstract/abstract_tag"
    require "hammer_builder/abstract/abstract_single_tag"
    require "hammer_builder/abstract/abstract_double_tag"

    # << faster then +
    # yield faster then block.call
    # accessing ivar and constant is faster then accesing hash or cvar
    # class_eval faster then define_method
    # beware of strings in methods -> creates a lot of garbage


    class_attribute :tags, :instance_writer => false
    self.tags = []

    protected

    # defines instance method for +tag+ in builder
    def self.define_tag(tag)
      tag = tag.to_s
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{tag}(*args, &block)
          flush
          @_#{tag}.open(*args, &block)
        end
      RUBY
      self.tags += [tag]
    end

    public


    # current tag being builded
    attr_accessor :_current
    alias_method :current, :_current
    alias_method :current=, :_current=


    # creates a new builder
    # This is quite expensive, HammerBuilder::Pool should be used
    def initialize()
      @_output  = ""
      @_stack   = []
      @_current = nil
      # tag classes initialization
      tags.each do |klass|
        instance_variable_set(:"@_#{klass}", self.class.dynamic_classes[klass.camelize.to_sym].new(self))
      end
    end

    # escapes +text+ to output
    def text(text)
      flush
      @_output << CGI.escapeHTML(text.to_s)
    end

    # unescaped +text+ to output
    def raw(text)
      flush
      @_output << text.to_s
    end

    # inserts +comment+
    def comment(comment)
      flush
      @_output << Strings::COMMENT_START << comment.to_s << Strings::COMMENT_END
    end

    # insersts CDATA with +content+
    def cdata(content)
      flush
      @_output << Strings::CDATA_START << content.to_s << Strings::CDATA_END
    end

    # renders xml version
    # @example
    #   xml_version # => <?xml version="1.0" encoding="UTF-8"?>
    def xml_version(version = '1.0', encoding = 'UTF-8')
      flush
      @_output << "<?xml version=\"#{version}\" encoding=\"#{encoding}\"?>\n"
    end

    # renders html5 doc type
    # @example
    #   doctype # => <!DOCTYPE html>
    def doctype
      flush
      @_output << "<!DOCTYPE html>\n"
    end

    # inserts xhtml5 header
    def xhtml5!
      xml_version
      doctype
    end

    # resets the builder to the state after creation - much faster then creating a new one
    def reset
      flush
      @_output.clear
      @_stack.clear
      self
    end

    #def capture
    #  flush
    #  _output = @_output.clone
    #  _stack  = @_stack.clone
    #  @_output.clear
    #  @_stack.clear
    #  yield
    #  to_xhtml
    #ensure
    #  @_output.replace _output
    #  @_stack.replace _stack
    #end

    # enables you to evaluate +block+ inside the builder with +variables+
    # @example
    #  HammerBuilder::Formatted.new.go_in('asd') do |string|
    #    div string
    #  end.to_html! #=> "<div>asd</div>"
    #
    def go_in(*variables, &block)
      instance_exec *variables, &block
      self
    end

    alias_method :dive, :go_in

    # sets instance variables when block is yielded
    # @param [Hash{String => Object}] instance_variables hash of names and values to set
    # @yield block when variables are set, variables are cleaned up afterwards
    def set_variables(instance_variables)
      instance_variables.each { |name, value| instance_variable_set("@#{name}", value) }
      yield(self)
      instance_variables.each { |name, _| remove_instance_variable("@#{name}") }
      self
    end

    # @return [String] output
    def to_xhtml()
      flush
      @_output.clone
    end

    # flushes open tag
    # @api private
    def flush
      if @_current
        @_current.flush
        @_current = nil
      end
    end

    # renders +object+ with +method+
    # @param [Object] object an object to render
    # @param [Symbol] method a method name which is used for rendering
    # @param args arguments passed to rendering method
    # @yield block passed to rendering method
    def render(object, method, *args, &block)
      object.__send__ method, self, *args, &block
    end

    # renders js
    # @option options [Boolean] :cdata (false) should cdata be used?
    # @example
    #   js 'a_js_function();' #=> <script type="text/javascript">a_js_function();</script>
    def js(js, options = { })
      use_cdata = options.delete(:cdata) || false
      script({ :type => "text/javascript" }.merge(options)) { use_cdata ? cdata(js) : text(js) }
    end

    # TODO update presentation
    # joins and renders +collection+ with +glue+
    # @param [Array<Proc, Object>] collection of objects or lambdas
    # @param [Proc, String] glue can be String which is rendered with #text or block to render
    # @yield how to render objects from +collection+, Proc in collection does not use this block
    # @example
    #   join([1, 1.2], lambda { text ', ' }) {|o| text o }        # => "1, 1.2"
    #   join([1, 1.2], ', ') {|o| text o }                        # => "1, 1.2"
    #   join([->{ text 1 }, 1.2], ', ') {|o| text o }             # => "1, 1.2"
    def join(collection, glue = nil, &it)
      # TODO as helper? two block method call #join(collection, &item).with(&glue)
      glue_block = case glue
        when String
          lambda { text glue }
        when Proc
          glue
        else
          lambda { }
      end

      collection.each_with_index do |obj, i|
        glue_block.call() if i > 0
        obj.is_a?(Proc) ? obj.call : it.call(obj)
      end
    end


  end
end
