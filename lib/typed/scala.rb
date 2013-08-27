module Typed
  module Scala
    module Variables
      ParseError = Class.new(SyntaxError)

      def self.apply(klass, type, caller, obj)
        name = parse(type, caller)
        define(klass, type, name, obj)
      end

      def self.define(klass, type, name, obj)
        vars = klass.__send__("#{type}s")
        vars[name] = obj
        
        klass.define_method(name) { attrs[name.to_s] }
        klass.define_method("#{name}=") {|v| attrs[name.to_s] = v }
      end

      def self.parse(type, caller)
        # "/tmp/adsvr/dsl.rb:23"
        case caller
        when %r{^(.*?):(\d+)}o
          file = $1
          line = $2.to_i
          @lines ||= File.readlines(file)
          case @lines[line-1].to_s
          when /^\s*#{type}\s+(\S+)\s+=/
            return $1
          else
            raise ParseError, "#{self} from file:#{file} (line: #{line})"
          end
        else
          raise ParseError, "#{self} from caller:#{caller}"
        end
      end

      def self.build(klass)
        attrs = Typed::Hash.new
        klass.vals.each_pair{|name, obj| attrs[name] = obj}
        klass.vars.each_pair{|name, obj| attrs[name] = obj}
        return attrs
      end
    end

    def attrs
      @attrs ||= Typed::Scala::Variables.build(self.class)
    end

    module Val
      def vals
        @vals ||= {}
      end

      def val(obj)
        Typed::Scala::Variables.apply(self, :val, caller[0], obj)
      end
    end

    module Var
      def vars
        @vars ||= {}
      end

      def var(obj)
        Typed::Scala::Variables.apply(self, :var, caller[0], obj)
      end
    end

    def self.included(klass)
      klass.extend Scala::Val
      klass.extend Scala::Var
    end
  end
end
