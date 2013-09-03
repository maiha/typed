module Typed
  module Scala

    ######################################################################
    ### Builder
    module Builder
      # Build instance from hash
      def build(hash = {})
        obj = new
        hash.each_pair do |k,v|
          obj[k] = v
        end
        return obj
      end

      # Build instance from array
      def apply(*args)
        if args.size > variables.size
          raise "#{self}.apply expect #{variables.size} args, but got #{args.size}"
        end

        obj = new
        variables.each_key do |name|
          val = args.shift or next
          obj[name] = val
        end
        return obj
      end

      # Build instance from array strictly. Raised when args size is differ.
      def apply!(*args)
        if args.size != variables.size
          raise "#{self}.apply expect #{variables.size} args, but got #{args.size}"
        end

        obj = new
        variables.each_key do |name|
          obj[name] = args.shift
        end
        return obj
      end
    end

  end
end
