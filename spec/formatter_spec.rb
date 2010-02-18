require File.expand_path('../spec_helper', __FILE__)

main = self

describe "IRB::Formatter::Default" do
  before do
    @formatter = IRB::Formatter::Default.new
    @context = IRB::Context.new(main)
  end
  
  it "returns a prompt string, displaying line number and code indentation level" do
    @formatter.prompt(@context).should == "irb(main):001:0> "
    @context.instance_variable_set(:@line, 23)
    @formatter.prompt(@context).should == "irb(main):023:0> "
    @context.source << "def foo"
    @formatter.prompt(@context).should == "irb(main):023:1> "
  end
  
  it "describes the context's object in the prompt" do
    o = Object.new
    @formatter.prompt(IRB::Context.new(o)).should == "irb(#{o.inspect}):001:0> "
  end
  
  it "returns a formatted exception message" do
    begin; DoesNotExist; rescue NameError => e; exception = e; end
    @formatter.exception(exception).should ==
      "NameError: uninitialized constant Bacon::Context::DoesNotExist\n\t#{exception.backtrace.join("\n\t")}"
  end
  
  it "prints the result" do
    @formatter.result(:foo => :foo).should == "=> {:foo=>:foo}"
  end
  
  it "prints that a syntax error occurred on the last line and reset the buffer to the previous line" do
    @formatter.syntax_error(2, "syntax error, unexpected '}'").should ==
      "SyntaxError: compile error\n(irb):2: syntax error, unexpected '}'"
  end
end

describe "IRB::Formatter::SimplePrompt" do
  before do
    @formatter = IRB::Formatter::SimplePrompt.new
  end
  
  it "returns a very simple prompt" do
    @formatter.prompt(nil).should == ">> "
  end
end