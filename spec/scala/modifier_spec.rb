require "spec_helper"

describe Typed::Scala do
  include_context "scala_source"

  ######################################################################
  ### Modifiers: OVERRIDE | LAZY

  # def isModifier: Boolean = in.token match {
#      case ABSTRACT | FINAL | SEALED | PRIVATE |
#           PROTECTED | OVERRIDE | IMPLICIT | LAZY => true
 
  # modifiers :     def isLocalModifier: Boolean = in.token match {
#      case ABSTRACT | FINAL | SEALED | IMPLICIT | LAZY => true

#  def isDclIntro: Boolean = in.token match {
#      case VAL | VAR | DEF | TYPE => true

#  describe "conflicted variable names" do
  pending "conflicted variable names" do
    context "(without override modifier)"

    let(:source) { <<-EOF
      class T
        include Typed::Scala
        
        val t = String
      end

      class U < T
        val t = Fixnum
      end
      EOF
    }

    specify do
      lambda { scala_source("User", source) }.should raise_error(TypeError)
    end

    specify do
      scala_source("User", source)
      T.vals.should == {}
    end

    context "(with override modifier)" do
    end
  end
end
