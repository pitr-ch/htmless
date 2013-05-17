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
