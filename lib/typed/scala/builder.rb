module Typed
  module Scala

    ######################################################################
    ### Builder
    module Builder
      def build(hash = {})
        obj = new
        hash.each_pair do |k,v|
          obj[k] = v
        end
        return obj
      end
    end

  end
end
