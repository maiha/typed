module Typed
  class Schema
    NotFound = Class.new(RuntimeError)
    Declared = Struct.new(:klass)

    class Implicit < Declared; end
    class Explicit < Declared; end
    class None     < Declared; end

    def self.schema?(obj)
      return true  if obj.is_a?(Class) or obj.is_a?(Module)
      return false if obj == [] or obj == {}
      return schema?(obj.first) if obj.is_a?(Array)
      return obj.first.any?{|i| schema?(i)} if obj.is_a?(::Hash)
      return false
    end

    def self.struct(obj)
      struct = Must::StructInfo.new(obj).compact
      struct = Array  if struct == []
      struct = ::Hash if struct == {}
      return struct
    end

    def initialize
      @types = ::Hash.new{ None.new }
    end

    def definition(key)
      @types[key]
    end

    def [](key)
      @types[key].klass
    end

    # return true if given data is accepted as schema
    def declared?(key, val)
      type  = @types[key]
      klass = type.klass

      if self.class.schema?(val)
        case type
        when Explicit
          raise TypeError, "%s is already typed as `%s'" % [key, klass.inspect]
        when Implicit
          # update schema if sub-class, otherwise raises
          val.must.struct(klass) {raise TypeError, "%s is already typed as `%s'" % [key, klass.inspect]}
          explicit(key, val)
        else
          explicit(key,val)
        end
        return true

      else
        case type
        when Explicit
          return false
        when Implicit
          # update schema if sub-struct
          struct = self.class.struct(val)
          if struct.must.struct?(klass)
            implicit(key, struct)
          end
        else          
          implicit(key, self.class.struct(val))
        end

        return false
      end
    end

    def validate!(key, val)
      klass = self[key] or
        raise Schema::NotFound, key.to_s

      if val.must.struct?(klass)
        return true 
      else
        expected = klass.inspect
        got      = Must::StructInfo.new(val).compact.inspect
        value    = val.inspect.truncate(200)
        raise TypeError, "%s(%s) got %s: %s" % [key, expected, got, value]
      end
    end

    private
      def implicit(key, val)
        @types[key] = Implicit.new(val)
      end

      def explicit(key, val)
        @types[key] = Explicit.new(val)
      end
  end
end
