# Htmless
# Copyright (C) 2015 Petr Chalupa <git@pitr.ch>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA

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




