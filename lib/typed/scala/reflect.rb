module Typed
  module Scala

    ######################################################################
    ### Reflect

    module Reflect
      def vals
        @typed_scala_vals ||= Typed::Scala::Variables.build_variables(self, :val)
      end

      def vars
        @typed_scala_vars ||= Typed::Scala::Variables.build_variables(self, :var)
      end
    end

  end
end
