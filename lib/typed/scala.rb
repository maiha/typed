module Typed
  module Scala

    ######################################################################
    ### instance methods

    include Enumerable

    def each(&block)
      __attrs__.each_pair(&block)
    end

    def __attrs__
      @__attrs__ ||= Typed::Scala::Variables.build_attrs(self.class)
    end

    def [](key)
      if __attrs__.schema.exist?(key)
        __attrs__[key.to_s]
      else
        raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
      end
    end

    def []=(key, val)
      if __attrs__.schema.exist?(key)
        if self.class.vals[key.to_s] and __attrs__.exist?(key)
          raise Typed::FixedValue, "reassignment to #{key}"
        end
        __attrs__[key.to_s] = val
      else
        raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
      end
    end

    ######################################################################
    ### provided api

    module Builder
      def build(hash = {})
        obj = new
        hash.each_pair do |k,v|
          obj[k] = v
        end
        return obj
      end
    end

    module Parser
      # Modifiers
      def override(*args)
      end

      def lazy(*args)    ; end

      # Declarations
      def val(obj)
        Typed::Scala::Variables.apply(self, :val, caller[0], obj)
      end

      def var(obj)
        Typed::Scala::Variables.apply(self, :var, caller[0], obj)
        return :var
      end
    end

    module Reflect
      def vals
        @typed_scala_vals ||= Typed::Scala::Variables.build_variables(self, :val)
      end

      def vars
        @typed_scala_vars ||= Typed::Scala::Variables.build_variables(self, :var)
      end
    end

    ######################################################################
    ### class schema

    module Variables
      ParseError = Class.new(SyntaxError)

      def self.apply(klass, type, caller, obj)
        name = parse(klass, type, caller)
        define(klass, type, name, obj)
      end

      def self.define(klass, type, name, obj)
        vars = klass.__send__("#{type}s")
        vars[name] = obj

        klass.class_eval <<-STR, __FILE__, __LINE__ + 1
          def #{name}
            self['#{name}']
          end

          def #{name}=(v)
            self['#{name}'] = v
          end
        STR
      end

      def self.parse(klass, type, caller)
        # "/tmp/adsvr/dsl.rb:23"
        case caller
        when %r{^(.*?):(\d+)}o
          file   = $1
          lineno = $2.to_i

          lines = (@lines ||= {})[klass] ||= File.readlines(file)
          case lines[lineno-1].to_s
          when /^\s*(override\s+)?(lazy\s+)?#{type}\s+(\S+)\s+=/
            override, lazy, name = $1, $2, $3
            return name
          else
            raise ParseError, "#{self} from #{caller}"
          end
        else
          raise ParseError, "#{self} from caller:#{caller}"
        end
      end

      def self.build_attrs(klass)
        attrs = Typed::Hash.new
        klass.vals.each_pair{|name, obj| attrs[name] = obj}
        klass.vars.each_pair{|name, obj| attrs[name] = obj}
        return attrs
      end

      def self.build_variables(klass, type)
        variables = ActiveSupport::OrderedHash.new

        klass.ancestors[1 .. -1].select{|k| k < Typed::Scala}.reverse.each do |k|
          k.instance_eval("[@typed_scala_#{type}s].compact").each do |hash|
            variables.merge!(hash)
          end
        end

        return variables
      end
    end

    ######################################################################
    ### module

    def self.included(klass)
      super

      klass.extend Scala::Reflect
      klass.extend Scala::Parser
      klass.extend Scala::Builder
    end
  end
end
