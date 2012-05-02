module Typed
  class Default
    def initialize(kvs)
      @kvs = kvs
    end

    def []=(key, val)
      return if @kvs.exist?(key.to_s)
      @kvs[key.to_s] = val
    end

    def regsiter_lazy(key, block)
      return if @kvs.exist?(key.to_s)
      raise ArgumentError, "Lazy default value needs block: #{key}" unless block
      @kvs[key.to_s] = Schema::LazyValue.new(block)
    end
  end
end
