module Typed
  module Scala
    ######################################################################
    ### instance methods

    module Accessors
      include Enumerable

      def each(&block)
        __attrs__.each_pair(&block)
      end

      def __attrs__
        @__attrs__ ||= Typed::Scala::Variables.build_attrs(self.class)
      end

      def [](key)
        if __attrs__.schema.exist?(key)
          __attrs__[key.to_s]
        else
          raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
        end
      end

      def []=(key, val)
        if __attrs__.schema.exist?(key)
          if self.class.vals[key.to_s] and __attrs__.exist?(key)
            raise Typed::FixedValue, "reassignment to #{key}"
          end
          __attrs__[key.to_s] = val
        else
          raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
        end
      end
    end
  end
end
