require 'hammer_builder/formatted'

warn '"hammer_builder/rails" is very early experiment'

module HammerBuilder::Rails
  class AbstractBuilder
    extend HammerBuilder::Helper

    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

  end

  ActionController::Renderers.add :hb do |klass_or_obj, options|
    obj = case
      when klass_or_obj.kind_of?(Class)
        klass_or_obj.new(self)
      when klass_or_obj.nil? || klass_or_obj == self
        self.class.to_s.gsub(/Controller/, 'Builder').constantize.new(self)
      else
        klass_or_obj
    end

    $hammer_builder_pool ||= HammerBuilder::SynchronizedPool.new(HammerBuilder::Formatted) # FIXME

    render(
        :text   => $hammer_builder_pool.get.
            go_in { render obj, "#{options[:method] || options[:template]}" }.to_html!,
        :layout => true)
  end


end




