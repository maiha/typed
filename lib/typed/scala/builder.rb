module Typed
  module Scala

    module Builder
      ######################################################################
      ### Build instances

      # check hash except arg size. (valid: return hash, invalid: raised)
      def check(hash)
        build(hash)
        return hash
      end

      # check hash strictly. (valid: return hash, invalid: raised)
      def check!(hash)
        build!(hash)
        return hash
      end

      # Build instance from hash (check only types)
      def build(hash)
        obj = new
        hash.each_pair do |k,v|
          obj[k] = v if variables[k]
        end
        return obj
      end

      # Build instance from hash strictly. (check both arg size and types)
      def build!(hash)
        hash.must(::Hash) { raise ArgumentError, "#{self} expects Hash, but got #{hash.class}" }

        if hash.size != variables.size
          keys1 = variables.keys
          keys2 = hash.keys.map(&:to_s)
          minus = (keys1 - keys2).map{|i| "-#{i}"}
          plus  = (keys2 - keys1).map{|i| "+#{i}"}
          
          msg = "#{self} expects #{variables.size}, but got #{hash.size} (%s)" % (minus + plus).join(",")
          raise Typed::SizeMismatch, msg
        end

        # 'build' just ignore unknown fields, but 'build!' raise errors
        obj = new
        hash.each_pair do |k,v|
          obj[k] = v
        end
        return obj
      end

      # Build instance from array. (check only types)
      def apply(*args)
        obj = new
        variables.each_key do |name|
          val = args.shift or next
          obj[name] = val
        end
        return obj
      end

      # Build instance from array strictly. (check both arg size and types)
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

      ######################################################################
      ### Extract attrs

      def attrs(obj)
        obj.must(self).__attrs__
      end

      def unbuild(obj)
        raise NotImplementedError
      end

      def unbuild!(obj)
        raise NotImplementedError
      end

      def unapply(obj)
        raise NotImplementedError
      end

      def unapply!(obj)
        raise NotImplementedError
      end
    end

  end
end
