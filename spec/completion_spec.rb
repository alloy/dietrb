require File.expand_path('../spec_helper', __FILE__)
require 'irb/ext/completion'

module CompletionHelper
  def complete(str)
    IRB::Completion.new(@context, str).results
  end
  
  def imethods(klass)
    klass.instance_methods.map(&:to_s)
  end
  
  def methods(object)
    object.methods.map(&:to_s)
  end
end

describe "IRB::Completion" do
  extend CompletionHelper
  
  it "quacks like a Proc" do
    IRB::Completion.call('//.').should == imethods(Regexp)
  end
end

class CompletionStub
  def self.a_cmethod
  end
  
  def an_imethod
  end
end

class Playground
  CompletionStub = Object.new
  def CompletionStub.singleton_method; end
  
  def a_local_method; end
end

$a_completion_stub = CompletionStub.new

describe "IRB::Completion, when the source ends with a period, " do
  describe "returns all public methods of the object that" do
    extend CompletionHelper
    
    before do
      @context = IRB::Context.new(Playground.new)
    end
    
    it "matches as a local variable" do
      @context.__evaluate__('foo = ::CompletionStub.new')
      complete('foo.').should == imethods(::CompletionStub)
      
      @context.__evaluate__('def foo.singleton_method; end')
      complete('foo.').should.include('singleton_method')
    end
    
    it "matches as a global variable" do
      complete('$a_completion_stub.').should == imethods(::CompletionStub)
    end
    
    it "matches as a local constant" do
      complete('CompletionStub.').should == methods(Playground::CompletionStub)
    end
    
    it "matches as a top level constant" do
      complete('::CompletionStub.').should == methods(::CompletionStub)
    end
  end
  
  describe "returns all public instance methods of the class that" do
    extend CompletionHelper
    
    it "matches as a Regexp literal" do
      complete('//.').should == imethods(Regexp)
      complete('/^(:[^:.]+)\.([^.]*)$/.').should == imethods(Regexp)
      complete('/^(#{oops})\.([^.]*)$/.').should == imethods(Regexp)
      complete('%r{/foo/.*/bar}.').should == imethods(Regexp)
    end
    
    it "matches as an Array literal" do
      complete('[].').should == imethods(Array)
      complete('[:ok, {}, "foo",].').should == imethods(Array)
      complete('[*foo].').should == imethods(Array)
      complete('%w{foo}.').should == imethods(Array)
      complete('%W{#{:foo}}.').should == imethods(Array)
    end
    
    # fails on MacRuby
    it "matches as a lambda literal" do
      complete('->{}.').should == imethods(Proc)
      complete('->{x=:ok}.').should == imethods(Proc)
      complete('->(x){x=:ok}.').should == imethods(Proc)
    end
    
    it "matches as a Hash literal" do
      complete('{}.').should == imethods(Hash)
      complete('{:foo=>:bar,}.').should == imethods(Hash)
      complete('{foo:"bar"}.').should == imethods(Hash)
    end
    
    it "matches as a Symbol literal" do
      complete(':foo.').should == imethods(Symbol)
      complete(':"foo.bar".').should == imethods(Symbol)
      complete(':"foo.#{"bar"}".').should == imethods(Symbol)
      complete(':\'foo.#{"bar"}\'.').should == imethods(Symbol)
      complete('%s{foo.bar}.').should == imethods(Symbol)
    end
    
    it "matches as a String literal" do
      complete("'foo\\'bar'.").should == imethods(String)
      complete('"foo\"bar".').should == imethods(String)
      complete('"foo#{"bar"}".').should == imethods(String)
      complete('%{foobar}.').should == imethods(String)
      complete('%q{foo#{:bar}}.').should == imethods(String)
      complete('%Q{foo#{:bar}}.').should == imethods(String)
    end
    
    it "matches as a Range literal" do
      complete('1..10.').should == imethods(Range)
      complete('1...10.').should == imethods(Range)
      complete('"a".."z".').should == imethods(Range)
      complete('"a"..."z".').should == imethods(Range)
    end
    
    it "matches as a Fixnum literal" do
      complete('42.').should == imethods(Fixnum)
      complete('+42.').should == imethods(Fixnum)
      complete('-42.').should == imethods(Fixnum)
      complete('42_000.').should == imethods(Fixnum)
    end
    
    it "matches as a Bignum literal as a Fixnum" do
      complete('100_000_000_000_000_000_000.').should == imethods(Fixnum)
      complete('-100_000_000_000_000_000_000.').should == imethods(Fixnum)
      complete('+100_000_000_000_000_000_000.').should == imethods(Fixnum)
    end
    
    it "matches as a Float with exponential literal" do
      complete('1.2e-3.').should == imethods(Float)
      complete('+1.2e-3.').should == imethods(Float)
      complete('-1.2e-3.').should == imethods(Float)
    end
    
    it "matches as a hex literal as a Fixnum" do
      complete('0xffff').should == imethods(Fixnum)
      complete('+0xffff').should == imethods(Fixnum)
      complete('-0xffff').should == imethods(Fixnum)
    end
    
    it "matches as a binary literal as a Fixnum" do
      complete('0b01011').should == imethods(Fixnum)
      complete('-0b01011').should == imethods(Fixnum)
      complete('+0b01011').should == imethods(Fixnum)
    end
    
    it "matches as an octal literal as a Fixnum" do
      complete('0377').should == imethods(Fixnum)
      complete('-0377').should == imethods(Fixnum)
      complete('+0377').should == imethods(Fixnum)
    end
    
    it "matches as a Float literal" do
      complete('42.0.').should == imethods(Float)
      complete('-42.0.').should == imethods(Float)
      complete('+42.0.').should == imethods(Float)
      complete('42_000.0.').should == imethods(Float)
    end
    
    it "matches as a Bignum float literal as a Float" do
      complete('100_000_000_000_000_000_000.0.').should == imethods(Float)
      complete('+100_000_000_000_000_000_000.0.').should == imethods(Float)
      complete('-100_000_000_000_000_000_000.0.').should == imethods(Float)
    end
  end
end