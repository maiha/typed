module Typed
  class Hash
    include Enumerable

    DEFAULT_OPTIONS = {
      :schema => true,
    }

    delegate :keys, :to=>"@hash"

    def initialize(options = {})
      @hash    = {}
      @options = DEFAULT_OPTIONS.merge(options.must(::Hash))
      @schema  = Schema.new
      @default = Default.new(self)
    end

    ######################################################################
    ### Default values

    def default(key = nil, &block)
      if key
        @default.regsiter_lazy(key, block)
      else
        @default
      end
    end

    ######################################################################
    ### Schema values

    def schema(key = nil)
      if key
        @schema[key]
      else
        @schema
      end
    end

    ######################################################################
    ### Accessor

    def [](key)
      if exist?(key)
        return load(key)
      else
        from = caller.is_a?(Array) ? caller.first : self.class
        raise NotDefined, "'#{key}' is not initialized\n#{from}"
      end
    end

    def update(key, val)
      @hash[key] = val
    end

    def []=(key, val)
      if check_schema?(key)
        case val
        when LazyValue
          # not schema
        when true,false,nil
          # TODO: How to treat these classes
        else
          @schema.declared?(key, val) and return
          @schema.validate!(key, val)
        end
      end
      update(key, val)
    end

    ######################################################################
    ### Testing

    def exist?(key)
      @hash.has_key?(key)
    end

    def set?(key)
      !! (exist?(key) && self[key])
    end

    def check(key, type = nil)
      return @schema.validate!(key, self[key]) unless type

      self[key].must.struct(type) {
        got   = Must::StructInfo.new(self[key]).compact.inspect
        value = self[key].inspect.truncate(200)
        raise TypeError, "%s(%s) got %s: %s" % [key, type.inspect, got, value]
      }
    end

    ######################################################################
    ### Hash compat

    def each(&block)
      keys.each do |key|
        val = self[key]
        block.call([key,val])
      end
    end

    def values
      keys.map{|key| self[key]}
    end

    ######################################################################
    ### Utils

    def inspect
      keys = @hash.keys.map(&:to_s).sort.join(',')
      "{#{keys}}"
    end

    private
      def load(key)
        # LazyValue should be evaluated at runtime
        value = @hash[key]
        if value.is_a?(LazyValue)
          value = value.block.call 
          self[key] = value
        end
        return value
      end

      def check_schema?(key)
        true
      end
  end
end
