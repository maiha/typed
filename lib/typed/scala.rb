module Typed
  module Scala
    autoload :Accessors, "typed/scala/accessors"
    autoload :Variables, "typed/scala/variables"
    autoload :Parser   , "typed/scala/parser"
    autoload :Builder  , "typed/scala/builder"
    autoload :Reflect  , "typed/scala/reflect"

    include Accessors

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
