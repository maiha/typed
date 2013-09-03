module Typed
  module Scala

    ######################################################################
    ### Parser
    module Parser
      # Modifiers
      def override(*args)
      end

      def lazy(*args)
      end

      # Declarations
      def val(obj)
        Typed::Scala::Variables.apply(self, :val, caller[0], obj)
      end

      def var(obj)
        Typed::Scala::Variables.apply(self, :var, caller[0], obj)
        return :var
      end
    end

  end
end
