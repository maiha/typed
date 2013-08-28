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

  describe "override" do
    before { scala_source("User", <<-EOF)
      class User
        include Typed::Scala
        
        val key  = String
        override var age  = Fixnum
      end
      EOF
    }

    specify do
    end

  end
end
