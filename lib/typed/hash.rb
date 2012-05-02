module Typed
  class Hash
    include Enumerable

    DEFAULT_OPTIONS = {
      :schema => true,
    }

    delegate :keys, :to=>"@hash"
    attr_reader :changes
    attr_reader :events

    def initialize(options = {})
      @hash    = {}
      @options = DEFAULT_OPTIONS.merge(options.must(::Hash))
      @schema  = Schema.new
      @default = Default.new(self)
      @changes = Changes.new
      @events  = Events.new
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
        val = load(key)
        @events.fire(:read, key.to_s, val)
        return val
      else
        from = caller.is_a?(Array) ? caller.first : self.class
        raise NotDefined, "'#{key}' is not initialized\n#{from}"
      end
    end

    def update(key, val)
      @hash[key.to_s] = val
      @events.fire(:write, key.to_s, val)
      @changes.touch(key)
    end

    def []=(key, val)
      declare = @schema.declare_method(val)
      case declare
      when Schema::LazyValue
        # not schema
        update(key, val)
      when Schema::Ambiguous
        # TODO: How to treat these classes
        update(key, val)
        check(key)
      when Schema::Explicit
        @schema.declare!(key, declare)
        check(key) if exist?(key)
      when Schema::Implicit
        @schema.declare!(key, declare)
        update(key, val)
        check(key)
      else
        raise NotImplementedError, "[BUG] no assignment logic for: #{declare.class}"
      end
    end

    ######################################################################
    ### Testing

    def exist?(key)
      @hash.has_key?(key.to_s)
    end

    def set?(key)
      !! (exist?(key) && self[key])
    end

    def check(key, type = nil)
      type ||= @schema[key]
      @schema.validate!(key, @hash[key.to_s], type)
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
      keys = @hash.keys.sort.join(',')
      "{#{keys}}"
    end

    private
      def load(key)
        value = @hash[key.to_s]

        # LazyValue should be evaluated at runtime
        return (self[key] = value.value.call) if value.is_a?(Schema::LazyValue)

        return value
      end

      def check_schema?(key)
        true
      end
  end
end
