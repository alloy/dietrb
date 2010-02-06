require File.expand_path('../spec_helper', __FILE__)

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
  
  it "returns the full buffered source, joined by newlines" do
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
  
  it "caches the reflection when possible" do
    @source << "def foo"
    reflection = @source.reflect
    @source.level
    @source.valid?
    @source.reflect.should == reflection
    
    @source << "end"
    @source.level
    new_reflection = @source.reflect
    new_reflection.should.not == reflection
    @source.valid?
    @source.reflect.should == new_reflection
  end
end

describe "IRB::Source::Reflector" do
  def reflect(source)
    IRB::Source::Reflector.new(source)
  end
  
  it "returns whether or not the source is a valid code block" do
    reflect("def foo").should.not.be.valid
    reflect("def foo; p :ok").should.not.be.valid
    reflect("def foo; p :ok; end").should.be.valid
  end
  
  it "returns the code block indentation level" do
    reflect("").level.should == 0
    reflect("class A").level.should == 1
    reflect("class A; def foo").level.should == 2
    reflect("class A; def foo; p :ok").level.should == 2
    reflect("class A; def foo; p :ok; end").level.should == 1
    reflect("class A; class B").level.should == 2
    reflect("class A; class B; def bar").level.should == 3
    reflect("class A; class B; def bar; p :ok; end").level.should == 2
    reflect("class A; class B; def bar; p :ok; end; end; end").level.should == 0
  end
  
  it "correctly increases and decreases the code block indentation level for keywords" do
    [
      "class A",
      "module A",
      "def foo",
      "begin",
      "if x == :ok",
      "unless x == :ko",
      "case x",
      "while x",
      "for x in xs",
      "x.each do"
    ].each do |open|
      reflect(open).level.should == 1
      reflect("#{open}\nend").level.should == 0
    end
  end
  
  it "correctly increases and decreases the code block indentation level for literals" do
    [
      ["lambda { |x|", "}"],
      ["{", "}"],
      ["[", "]"]
    ].each do |open, close|
      reflect(open).level.should == 1
      reflect("#{open}\n#{close}").level.should == 0
    end
  end
end