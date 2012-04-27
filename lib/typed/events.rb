module Typed
  class Events
    def initialize
      @callbacks = {}
    end

    def on(type, &block)
      event(type) << block
    end

    def fire(type, key, val)
      event(type).each{|block| block.call(key,val)}
    end

    private
      def event(type)
        @callbacks[type] ||= []
      end
  end
end

