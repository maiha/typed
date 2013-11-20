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
        if self.class.variables[key.to_s]
          self.__send__(key)
        else
          raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
        end
      end

      def []=(key, val)
        if self.class.variables[key.to_s]
          self.__send__("#{key}=", val)
        else
          raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
        end
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        return __attrs__ == other.__attrs__
      end

      def to_s
        __attrs__.inspect
      end
    end
  end
end
