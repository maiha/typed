module Typed
  class Default
    def initialize(kvs)
      @kvs = kvs
    end

    def []=(key, val)
      return if @kvs.exist?(key.to_s)
      @kvs[key.to_s] = val
    end

    def merge!(hash)
      hash.each_pair do |key, val|
        self[key] = val
      end
    end

    def register_lazy(key, block)
      return if @kvs.exist?(key.to_s)
      raise ArgumentError, "Lazy default value needs block: #{key}" unless block
      @kvs[key.to_s] = Schema::LazyValue.new(block)
    end
  end
end
