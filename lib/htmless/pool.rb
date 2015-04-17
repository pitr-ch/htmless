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

module Htmless

  # Creating builder instances is expensive, therefore you can use Pool to go around that
  # @example
  #   pool = Pool.new Formatted
  #   pool.get.go_in do
  #     # some rendering
  #   end.to_xhtml! # => output and releases the builder to pool
  class Pool

    module Helper
      def release
        @_origin.release self
      end

      # @return [String] output and releases the builder to pool
      def to_html!
        to_html
      ensure
        release
      end
    end

    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @pool  = []
      klass.send :include, Helper
    end

    # This the preferred way of getting new Builder. If you forget to release it, it does not matter -
    # builder gets GCed after you lose reference
    # @return [Abstract]
    def get
      if @pool.empty?
        @klass.new.instance_exec(self) { |origin| @_origin = origin; self }
      else
        @pool.pop
      end
    end

    # returns +builder+ back into pool *DONT* forget to lose the reference to the +builder+
    # @param [Abstract]
    def release(builder)
      raise TypeError unless builder.is_a? @klass
      builder.reset
      @pool.push builder
      nil
    end

    def size
      @pool.size
    end
  end

  class SynchronizedPool < Pool
    def initialize(klass)
      super(klass)
      @mutex = Mutex.new
    end

    def get
      @mutex.synchronize { super }
    end

    def release(builder)
      @mutex.synchronize { super(builder) }
    end

  end
end
