require File.expand_path('../spec_helper', __FILE__)

main = self

describe "IRB::Context" do
  before do
    @context = IRB::Context.new(main)
  end
  
  it "initializes with an object and stores a copy of its binding" do
    @context.object.should == main
    eval("self", @context.binding).should == main
    eval("x = :ok", @context.binding)
    eval("y = x", @context.binding)
    eval("y", @context.binding).should == :ok
  end
  
  it "initializes with an 'empty' state" do
    @context.line.should == 1
    @context.source.should.be.instance_of IRB::Source
    @context.source.to_s.should == ""
  end
  
  it "does not use the same binding copy of the top level object" do
    lambda { eval("x", @context.binding) }.should.raise NameError
  end
  
  it "evaluates code with the object's binding" do
    @context.evaluate("self").should == main
  end
  
  it "coerces the given source to a string first" do
    o = Object.new
    def o.to_s; "self"; end
    @context.evaluate(o).should == main
  end
end