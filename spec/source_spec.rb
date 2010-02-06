require 'rubygems'
require 'bacon'

ROOT = File.expand_path('../../', __FILE__)
$:.unshift File.join(ROOT, 'lib')

require 'irb/source'

describe "IRB::Source" do
  before do
    @source = IRB::Source.new
  end
  
  it "initializes with an empty buffer" do
    @source.buffer.should == []
  end
  
  it "appends source to the buffer, removing trailing newlines" do
    @source << "foo\n"
    @source << "bar\r\n"
    @source.buffer.should == %w{ foo bar }
  end
  
  it "returns the full buffered source, joined by a newline" do
    @source.source.should == ""
    @source << "foo\n"
    @source.source.should == "foo"
    @source << "bar\r\n"
    @source.source.should == "foo\nbar"
  end
  
  it "returns that the accumulated source is a valid code block" do
    [
      ["def foo", "p :ok", "end"],
      ["class A; def", "foo(x); p x", "end; end"]
    ].each do |buffer|
      IRB::Source.new(buffer).should.be.valid
    end
  end
  
  it "returns that the accumulated source is not a valid code block" do
    [
      ["def foo", "p :ok"],
      ["class A; def", "foo(x); p x", "end"]
    ].each do |buffer|
      IRB::Source.new(buffer).should.not.be.valid
    end
  end
end