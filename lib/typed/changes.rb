module Typed
  class Changes
    def initialize
      @hash = {}
    end

    def reset
      @hash = {}
    end

    def touch(key)
      @hash[key.to_s] = Time.now
    end

    def keys
      @hash.to_a.sort_by(&:last).map(&:first)
    end
  end
end

