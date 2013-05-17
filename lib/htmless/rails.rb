require 'htmless/formatted'

warn '"htmless/rails" is very early experiment'

module Htmless::Rails
  class AbstractBuilder
    extend Htmless::Helper

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

    $htmless_pool ||= Htmless::SynchronizedPool.new(Htmless::Formatted) # FIXME

    render(
        :text   => $htmless_pool.get.
            go_in { render obj, "#{options[:method] || options[:template]}" }.to_html!,
        :layout => true)
  end


end




