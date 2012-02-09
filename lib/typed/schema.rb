module Typed
  class Schema
    NotFound = Class.new(RuntimeError)

    def initialize(kvs)
      @kvs = kvs
      @types = {}
    end

    def exist?(key)
      @types.has_key?(key)
    end

    def [](key)
      @types[key]
    end

    def []=(key, val)
      if exist?(key)
        raise "%s is already typed as `%s'" % [key, @types[key].inspect]
      else
        @types[key] = val
      end
    end

    def check!(key, val)
      struct = @types[key] or
        raise Schema::NotFound, key.to_s

      if val.must.struct?(struct)
        return true 
      else
        expected = @types[key].inspect
        got      = Must::StructInfo.new(val).compact.inspect
        value    = val.inspect.truncate(200)
        raise TypeError, "%s(%s) got %s: %s" % [key, expected, got, value]
      end
    end
  end
end
