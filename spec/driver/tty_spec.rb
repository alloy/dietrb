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
end