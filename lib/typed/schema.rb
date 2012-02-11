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
      @types[key]
    end

    def [](key)
      @types[key].value
    end

    def declare!(key, val)
      type  = @types[key]
      klass = type.value

      if self.class.schema?(val)
        case type
        when Explicit
          raise TypeError, "%s has already been declared as `%s'" % [key, klass.inspect]
        when Implicit
          # update schema if sub-class, otherwise raises
          val.must.struct(klass) {raise TypeError, "%s has already been typed as `%s'" % [key, klass.inspect]}
        end
        explicit(key, val)

      else
        case type
        when Explicit
          # nop
        when Implicit
          # update schema if sub-struct
          struct = self.class.struct(val)
          if struct.must.struct?(klass)
            implicit(key, struct)
          end
        else          
          implicit(key, self.class.struct(val))
        end
      end
    end

    def validate!(key, val, klass)
      return true unless klass
#      raise Schema::NotFound, key.to_s unless klass

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
