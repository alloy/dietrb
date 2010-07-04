require File.expand_path('../../spec_helper', __FILE__)
require 'tempfile'

describe "IRB::IO::Readline" do
  before do
    @output = File.new("/tmp/dietrb-output-#{Time.now.to_i}", 'w+')
    @io = IRB::IO::Readline.new($stdin, @output)
  end
  
  after do
    @output.close
    File.unlink(@output.path)
  end
  
  it "returns the input and output objects" do
    @io.input.should == $stdin
    @io.output.should == @output
  end
  
  it "receives a prompt and should save the history" do
    def Readline.readline(prompt, save_history); @received = [prompt, save_history]; end
    @io.readline('PROMPT')
    Readline.instance_variable_get(:@received).should == ['PROMPT', true]
  end
  
  it "forwards #puts to the output object" do
    @io.puts("chunky banana")
    @output.rewind
    @output.read.should == "chunky banana\n"
  end
end