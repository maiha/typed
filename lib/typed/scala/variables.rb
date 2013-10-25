module Typed
  module Scala
    ######################################################################
    ### class schema

    module Variables
      ParseError = Class.new(SyntaxError)

      Declaration = Struct.new(:klass, :name, :type, :mods, :value)

      def apply(klass, type, caller, obj)
        dcl = parse(klass, type, caller)
        dcl.value = (obj == Typed::Hash) ? ::Hash : obj

        define_schema(dcl)
        define_method(dcl)
      end

      def define_schema(dcl)
        vars = dcl.klass.__send__("#{dcl.type}s")
        vars[dcl.name] = dcl.value

        # new feature
        dcl.klass.variables[dcl.name] = dcl.value
      end

      def define_method(dcl)
        name  = dcl.name
        klass = dcl.klass
        typed = [dcl.value].flatten.map{|k| (k == ::Hash) ? '::Hash' : k.to_s}.join(', ')

        dcl.klass.class_eval <<-STR, __FILE__, __LINE__ + 1
          def #{name}
            k = '#{name}'
            h = __attrs__
            raise Typed::NotDefined, "'#{name}' is not initialized" unless h.key?(k)
            return h[k]
          end

          def #{name}=(v)
            k = '#{name}'
            h = __attrs__
            if self.class.vals[k] and h.key?(k)
              raise Typed::FixedValue, "reassignment to %s" % k
            end
            v.must(#{typed}) { raise TypeError, '#{klass}##{name}= expected #{typed} but got %s' % [v.class] }
            h[k] = v
          end
        STR
      end

      def parse(klass, type, caller)
        # "/tmp/adsvr/dsl.rb:23"
        case caller
        when %r{^(.*?):(\d+)}o
          file   = $1
          lineno = $2.to_i

          lines = (@lines ||= {})[klass] ||= File.readlines(file)
          case lines[lineno-1].to_s
          when /^\s*(override\s+)?(lazy\s+)?(val|var)\s+(\S+)\s+=/
            mods = [$1, $2].compact.map(&:strip)
            type = $3
            name = $4
            return Declaration.new(klass, name, type, mods)
          else
            raise ParseError, "#{self} from #{caller}"
          end
        else
          raise ParseError, "#{self} from caller:#{caller}"
        end
      end

      def build_attrs(klass)
        return {}
      end

      def build(klass)
        variables = ActiveSupport::OrderedHash.new

        klass.ancestors[1 .. -1].select{|k| k < Typed::Scala}.reverse.each do |k|
          k.instance_eval("[@variables].compact").each do |hash|
            variables.merge!(hash)
          end
        end

        return variables
      end

      def build_variables(klass, type)
#        variables = Typed::Hash.new
        variables = ActiveSupport::OrderedHash.new

        klass.ancestors[1 .. -1].select{|k| k < Typed::Scala}.reverse.each do |k|
          k.instance_eval("[@typed_scala_#{type}s].compact").each do |hash|
            variables.merge!(hash)
          end
        end

        return variables
      end

      extend self
    end

  end
end
