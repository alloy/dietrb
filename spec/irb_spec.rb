require File.expand_path('../spec_helper', __FILE__)

describe "Kernel::IRB()" do
  it "creates a new context for the given object and runs it" do
    Readline.stub_input("::IRBRan = self")
    o = Object.new
    IRB(o)
    IRBRan.should == o
  end
end