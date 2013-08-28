module Typed
  module Scala

    ######################################################################
    ### instance methods

    def attrs
      @attrs ||= Typed::Scala::Variables.build_attrs(self.class)
    end

    def [](key)
      if attrs.schema.exist?(key)
        attrs[key.to_s]
      else
        raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
      end
    end

    def []=(key, val)
      if attrs.schema.exist?(key)
        if self.class.vals[key.to_s] and attrs.exist?(key)
          raise Typed::FixedValue, "reassignment to #{key}"
        end
        attrs[key.to_s] = val
      else
        raise Typed::NotDefined, "#{key} is not a member of #{self.class}"
      end
    end

    ######################################################################
    ### provided api

    module Val
      def vals
        @typed_scala_vals ||= Typed::Scala::Variables.build_variables(self, :val)
      end

      def val(obj)
        Typed::Scala::Variables.apply(self, :val, caller[0], obj)
      end
    end

    module Var
      def vars
        @typed_scala_vars ||= Typed::Scala::Variables.build_variables(self, :var)
      end

      def var(obj)
        Typed::Scala::Variables.apply(self, :var, caller[0], obj)
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
        
        klass.class_eval do
          define_method(name) { self[name.to_s] }
          define_method("#{name}=") {|v| self[name.to_s] = v }
        end
      end

      def self.parse(klass, type, caller)
        # "/tmp/adsvr/dsl.rb:23"
        case caller
        when %r{^(.*?):(\d+)}o
          file   = $1
          lineno = $2.to_i

          lines = (@lines ||= {})[klass] ||= File.readlines(file)
          case lines[lineno-1].to_s
          when /^\s*#{type}\s+(\S+)\s+=/
            return $1
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

      klass.extend Scala::Val
      klass.extend Scala::Var
    end
  end
end
