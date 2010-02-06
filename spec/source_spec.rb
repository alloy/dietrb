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
  
  it "returns the current code block indentation level" do
    @source.level.should == 0
    @source << "class A"
    @source.level.should == 1
    @source << "  def foo"
    @source.level.should == 2
    @source << "    p :ok"
    @source.level.should == 2
    @source << "  end"
    @source.level.should == 1
    @source << "  class B"
    @source.level.should == 2
    @source << "    def bar"
    @source.level.should == 3
    @source << "      p :ok; end"
    @source.level.should == 2
    @source << "  end; end"
    @source.level.should == 0
  end
end

describe "IRB::Source::Reflector" do
  def level(source)
    IRB::Source::Reflector.new(source).level
  end
  
  it "returns the code block indentation level" do
    level("").should == 0
    level("class A").should == 1
    level("class A; def foo").should == 2
    level("class A; def foo; p :ok").should == 2
    level("class A; def foo; p :ok; end").should == 1
    level("class A; class B").should == 2
    level("class A; class B; def bar").should == 3
    level("class A; class B; def bar; p :ok; end").should == 2
    level("class A; class B; def bar; p :ok; end; end; end").should == 0
  end
end