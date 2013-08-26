require "must"
require "active_support/core_ext"
require "typed/version"
require "typed/hash"

module Typed
  NotDefined = Class.new(RuntimeError)

  autoload :Schema , "typed/schema"
  autoload :Default, "typed/default"
  autoload :Changes, "typed/changes"
  autoload :Events , "typed/events"
  autoload :Scala  , "typed/scala"
end

