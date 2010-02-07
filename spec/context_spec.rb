require File.expand_path('../spec_helper', __FILE__)
require 'tempfile'

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
  
  it "returns a prompt string, displaying line number and code indentation level" do
    @context.prompt.should == "irb(main):001:0> "
    @context.instance_variable_set(:@line, 23)
    @context.prompt.should == "irb(main):023:0> "
    @context.source << "def foo"
    @context.prompt.should == "irb(main):023:1> "
  end
  
  it "describes the context's object in the prompt" do
    @context.prompt.should == "irb(main):001:0> "
    o = Object.new
    IRB::Context.new(o).prompt.should == "irb(#{o.inspect}):001:0> "
  end
end

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

describe "IRB::Context, when receiving input" do
  before do
    @context = IRB::Context.new(main)
  end
  
  it "prints the prompt, reads a line, saves it to the history and returns it" do
    Readline.stub_input("def foo")
    @context.readline.should == "def foo"
    Readline.received.should == ["irb(main):001:0> ", true]
  end
  
  it "adds the received code, as long as available, to the source buffer while running" do
    Readline.stub_input("def foo", "p :ok")
    @context.run
    @context.source.to_s.should == "def foo\np :ok"
  end
  
  it "evaluates the buffered source once it's a valid code block" do
    Readline.stub_input("def foo", ":ok", "end; p foo")
    def @context.evaluate(source)
      @evaled_source = source
    end
    @context.run
    source = @context.instance_variable_get(:@evaled_source)
    source.to_s.should == "def foo\n:ok\nend; p foo"
  end
end