require 'spec_helper'

shared_context "scala_source" do
  before { @loaded = [] }
  after  { @loaded.each{|klass| Object.__send__(:remove_const, klass) if Object.const_defined?(klass) } }
      
  def scala_source(klass, code)
    path = tmp_path("scala/source.rb")
    path.parent.mkpath
    path.open("w+"){|f| f.puts(code) }
    load(path.to_s)
    @loaded << klass
  end
end
