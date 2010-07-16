require File.expand_path('../../spec_helper', __FILE__)
require 'irb/driver/tty'

describe "IRB::Driver::TTY" do
  before do
    @driver = IRB::Driver::TTY.new(InputStub.new, OutputStub.new)
    @context = IRB::Context.new(Object.new)
  end
  
  it "prints the prompt and reads a line of input" do
    @driver.input.stub_input "calzone"
    @driver.readline(@context).should == "calzone"
    @driver.output.printed.should == @context.prompt
  end
  
  it "consumes input" do
    @driver.input.stub_input "calzone"
    @driver.consume(@context).should == "calzone"
  end
  
  it "clears the context buffer if an Interrupt signal is received while consuming input" do
    @context.process_line("class A")
    def @driver.readline(_); raise Interrupt; end
    @driver.consume(@context).should == ""
    @context.source.to_s.should == ""
  end

  it "feeds input into a given context" do
    $from_context = false
    @driver.input.stub_input "$from_context = true", "exit"
    @driver.run(@context)
    $from_context.should == true
  end

  it "makes sure there's one global output redirector while running a context" do
    before = $stdout
    $from_context = nil
    @driver.input.stub_input "$from_context = $stdout", "exit"
    @driver.run(@context)
    $from_context.class == IRB::Driver::OutputRedirector
    $stdout.should == before
  end
end
