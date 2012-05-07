module Typed
  class Schema
    NotFound = Class.new(RuntimeError)
    Declared = Struct.new(:value)
    class Ambiguous < Declared; end
    class Implicit  < Declared; end
    class Explicit  < Declared; end
    class Nothing   < Declared; end
    class LazyValue < Declared; end

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

    def self.declare_method(val)
      case val
      when LazyValue; val
      when true,false,nil; Ambiguous.new(val)
      else; schema?(val) ? Explicit.new(val) : Implicit.new(val)
      end
    end

    delegate :schema?, :declare_method, :to => "self.class"

    def initialize
      @types = ::Hash.new{ Nothing.new }
    end

    def definition(key)
      @types[key.to_s]
    end

    def [](key)
      @types[key.to_s].value
    end

    def declare!(key, declare)
      case declare.must.be.kind_of(Explicit, Implicit)
      when Explicit
        case @types[key.to_s]
        when Explicit
          raise TypeError, "%s has already been declared as `%s'" % [key, @types[key.to_s].value.inspect]
        when Implicit
          # update schema if sub-class, otherwise raises
          declare.value.must.struct?(@types[key.to_s].value) or
            raise TypeError, "%s has already been typed as `%s'" % [key, @types[key.to_s].value.inspect]
        end
        explicit(key, declare)

      when Implicit
        case @types[key.to_s]
        when Explicit
          # nop
        when Implicit
          # update schema if sub-struct
          struct = self.class.struct(declare.value)
          if struct.must.struct?(@types[key.to_s].value)
            implicit(key, struct)
          end
        else          
          implicit(key, self.class.struct(declare.value))
        end
      end
    end

    def validate!(key, val, klass)
      return true unless klass
#      raise Schema::NotFound, key.to_s unless klass

      if struct?(val, klass)
        return true 
      else
        expected = klass.inspect
        got      = Must::StructInfo.new(val).compact.inspect
        value    = val.inspect.truncate(200)
        raise TypeError, "%s(%s) got %s: %s" % [key, expected, got, value]
      end
    end

    private
      def struct?(val, klass)
        return true if klass == Object
        return val.must.struct?(klass)
      end

      def implicit(key, val)
        val = Implicit.new(val) unless val.is_a?(Implicit)
        @types[key.to_s] = val
      end

      def explicit(key, val)
        val = Explicit.new(val) unless val.is_a?(Explicit)
        @types[key.to_s] = val
      end
  end
end
