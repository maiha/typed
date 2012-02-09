module Typed
  class Default
    def initialize(kvs)
      @kvs = kvs
    end

    def []=(key, val)
      return if @kvs.exist?(key)
      @kvs[key] = val
    end

    def regsiter_lazy(key, block)
      return if @kvs.exist?(key)
      raise ArgumentError, "Lazy default value needs block: #{key}" unless block
      @kvs[key] = LazyValue.new(block)
    end
  end
end
