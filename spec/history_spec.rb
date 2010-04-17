require File.expand_path('../spec_helper', __FILE__)
require "tempfile"

describe "IRB::History" do
  it "stores the history by default in ~/.irb_history" do
    IRB::History.file.should == File.expand_path("~/.irb_history")
  end
  
  before do
    @file = Tempfile.new("irb_history.txt")
    IRB::History.file = @file.path
  end
  
  after do
    @file.close
  end
  
  it "adds input to the history file" do
    IRB::History.input "puts :ok"
    @file.rewind; @file.read.should == "puts :ok\n"
    IRB::History.input "foo(x)"
    @file.rewind; @file.read.should == "puts :ok\nfoo(x)\n"
  end
  
  it "returns the contents of the history file as an array of lines" do
    IRB::History.input "puts :ok"
    IRB::History.to_a.should == ["puts :ok"]
    IRB::History.input "foo(x)"
    IRB::History.to_a.should == ["puts :ok", "foo(x)"]
  end
  
  it "stores the contents of the history file in Readline::HISTORY once" do
    Readline::HISTORY.clear
    
    IRB::History.input "puts :ok"
    IRB::History.input "foo(x)"
    
    IRB::History.init
    IRB::History.init
    
    Readline::HISTORY.to_a.should == ["puts :ok", "foo(x)"]
  end
end