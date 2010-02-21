require File.expand_path('../spec_helper', __FILE__)
require 'tempfile'

def stub_Readline
  class << Readline
    attr_reader :received
    
    def stub_input(*input)
      @input = input
    end
    
    def readline(prompt, history)
      @received = [prompt, history]
      @input.shift
    end
  end
end
stub_Readline

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
  
  it "initializes with an object and an explicit binding" do
    context = IRB::Context.new(Object.new, TOPLEVEL_BINDING)
    eval("class InTopLevel; end", context.binding)
    lambda { ::InTopLevel }.should.not.raise NameError
  end
  
  it "initializes with an 'empty' state" do
    @context.line.should == 1
    @context.source.should.be.instance_of IRB::Source
    @context.source.to_s.should == ""
  end
  
  it "does not use the same binding copy of the top level object" do
    lambda { eval("x", @context.binding) }.should.raise NameError
  end
  
  it "makes itself the current running context during the runloop and resigns once it's done" do
    IRB::Context.current.should == nil
    
    Readline.stub_input("current_during_run = IRB::Context.current")
    @context.run
    eval('current_during_run', @context.binding).should == @context
    
    IRB::Context.current.should == nil
  end
end

describe "IRB::Context, when evaluating source" do
  before do
    @context = IRB::Context.new(main)
    def @context.puts(string); @printed = string; end
    def @context.printed;      @printed;          end
  end
  
  it "evaluates code with the object's binding" do
    @context.__evaluate__("self").should == main
  end
  
  it "prints the result" do
    @context.evaluate("Hash[:foo, :foo]")
    printed = @context.instance_variable_get(:@printed)
    printed.should == "=> {:foo=>:foo}"
  end
  
  it "assigns the result to the local variable `_'" do
    result = @context.evaluate("Object.new")
    @context.evaluate("_").should == result
    @context.evaluate("_").should == result
  end
  
  it "coerces the given source to a string first" do
    o = Object.new
    def o.to_s; "self"; end
    @context.evaluate(o).should == main
  end
  
  it "rescues any type of exception" do
    lambda {
      @context.evaluate("DoesNotExist")
      @context.evaluate("raise Exception")
    }.should.not.raise
  end
  
  it "prints the exception that occurs" do
    @context.evaluate("DoesNotExist")
    @context.printed.should.match /^NameError:.+DoesNotExist/
  end
  
  it "uses the line number of the *first* line in the buffer, for the line parameter of eval" do
    @context.process_line("DoesNotExist")
    @context.printed.should.match /\(irb\):1:in/
    @context.process_line("class A")
    @context.process_line("DoesNotExist")
    @context.process_line("end")
    @context.printed.should.match /\(irb\):3:in.+\(irb\):2:in/m
  end
end

describe "IRB::Context, when receiving input" do
  before do
    @context = IRB::Context.new(main)
  end
  
  it "prints the prompt, reads a line, saves it to the history and returns it" do
    Readline.stub_input("def foo")
    @context.readline.should == "def foo"
    Readline.received.should == ["irb(main):001:0> ", true]
  end
  
  it "processes the output" do
    Readline.stub_input("def foo")
    def @context.process_line(line); @received = line; false; end
    @context.run
    @context.instance_variable_get(:@received).should == "def foo"
  end
  
  it "adds the received code to the source buffer" do
    @context.process_line("def foo")
    @context.process_line("p :ok")
    @context.source.to_s.should == "def foo\np :ok"
  end
  
  it "clears the source buffer when an Interrupt signal is received" do
    begin
      @context.process_line("def foo")
      
      def Readline.readline(*args)
        unless @raised
          @raised = true
          raise Interrupt
        end
      end
      
      lambda { @context.run }.should.not.raise Interrupt
      @context.source.to_s.should == ""
    ensure
      stub_Readline
    end
  end
  
  it "increases the current line number" do
    @context.line.should == 1
    @context.process_line("def foo")
    @context.line.should == 2
    @context.process_line("p :ok")
    @context.line.should == 3
  end
  
  it "evaluates the buffered source once it's a valid code block" do
    def @context.evaluate(source); @evaled = source; end
    
    @context.process_line("def foo")
    @context.process_line(":ok")
    @context.process_line("end; p foo")
    
    source = @context.instance_variable_get(:@evaled)
    source.to_s.should == "def foo\n:ok\nend; p foo"
  end
  
  it "prints that a syntax error occurred on the last line and reset the buffer to the previous line" do
    def @context.puts(str); @printed = str; end
    
    @context.process_line("def foo")
    @context.process_line("  };")
    
    @context.source.to_s.should == "def foo"
    printed = @context.instance_variable_get(:@printed)
    printed.should == "SyntaxError: compile error\n(irb):2: syntax error, unexpected '}'"
  end
  
  it "returns whether or not the runloop should continue, but only if the level is 0" do
    @context.process_line("def foo").should == true
    @context.process_line("quit").should == true
    @context.process_line("end").should == true
    
    @context.process_line("quit").should == false
  end
  
  it "exits the runloop if the user wishes so" do
    Readline.stub_input("quit", "def foo")
    def @context.process_line(line); @received = line; super; end
    @context.run
    @context.instance_variable_get(:@received).should.not == "def foo"
  end
end