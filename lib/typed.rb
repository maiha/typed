require "must"
require "active_support/core_ext"
require "typed/version"
require "typed/hash"

module Typed
  NotDefined = Class.new(RuntimeError)

  autoload :Default, "typed/default"
  autoload :Schema , "typed/schema"
end

