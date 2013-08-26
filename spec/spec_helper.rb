$:.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'typed'

def tmp_path(file)
  Pathname(File.dirname(__FILE__)) + "../tmp" + file
end
