module Typed
  module Scala
    def vars
      unless @vars
        vars = Typed::Hash.new
        self.class.types.each_pair do |name, obj|
#          vars.default[name] = obj
          vars[name] = obj
        end
        @vars = vars
      end
      return @vars
    end

    def types
      self.class.types
    end

    module Var
      ParseError = Class.new(SyntaxError)
      def types
        @types ||= {}
      end

      def register_var(name, obj)
        types[name] = obj
        
        define_method(name) { vars[name.to_s] }
        define_method("#{name}=") {|v| vars[name.to_s] = v }
      end

      def parse_var_name(caller)
        # "/tmp/adsvr/dsl.rb:23"
        case caller
        when %r{^(.*?):(\d+)}o
          file = $1
          line = $2.to_i
          @lines ||= File.readlines(file)
          case @lines[line-1].to_s
          when /^\s*var\s+(\S+)\s+=/o
            return $1
          else
            raise ParseError, "#{self} from file:#{file} (line: #{line})"
          end
        else
          raise ParseError, "#{self} from caller:#{caller[0]}"
        end
      end

      def var(obj)
        name = parse_var_name(caller[0])
        register_var(name, obj)
      end
    end

    def self.included(klass)
      klass.extend Scala::Var
    end
  end
end
