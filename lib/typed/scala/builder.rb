module Typed
  module Scala

    ######################################################################
    ### Builder
    module Builder
      def check(hash)
        build(hash)
        return hash
      end

      # Build instance from hash
      def build(hash)
        hash.must(::Hash) { raise ArgumentError, "#{self} expects Hash, but got #{hash.class}" }

        if hash.size != variables.size
          keys1 = variables.keys
          keys2 = hash.keys.map(&:to_s)
          minus = (keys1 - keys2).map{|i| "-#{i}"}
          plus  = (keys2 - keys1).map{|i| "+#{i}"}
          
          msg = "#{self} expects #{variables.size}, but got #{hash.size} (%s)" % (minus + plus).join(",")
          raise Typed::SizeMismatch, msg
        end

        obj = new
        hash.each_pair do |k,v|
          obj[k] = v
        end
        return obj
      end

      # Build instance from array
      def apply(*args)
        if args.size > variables.size
          raise Typed::SizeMismatch, "#{self}.apply expects #{variables.size} args, but got #{args.size}"
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
          raise Typed::SizeMismatch, "#{self} expects #{variables.size} args, but got #{args.size}"
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
