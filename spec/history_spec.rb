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
  
  it "returns the same input value" do
    IRB::History.input("foo(x)").should == "foo(x)"
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
    
    IRB::History.new.should == IRB::History
    IRB::History.new.should == IRB::History
    
    Readline::HISTORY.to_a.should == ["puts :ok", "foo(x)"]
  end
end

class << IRB::History
  attr_reader :printed
  
  def reset
    @printed = ""
  end
  
  def print(s)
    printed << s
  end
  
  def puts(s)
    printed << "#{s}\n"
  end
end

describe "IRB::History, concerning the user api" do
  it "shows by default a maximum of 50 history entries" do
    IRB::History.max_entries_in_overview.should == 50
  end
  
  before do
    @sources = [
      "puts :ok",
      "foo(x)",
      "class A",
      "  def bar",
      "    p :ok",
      "  end",
      "end",
    ]
    
    Readline::HISTORY.clear
    @sources.each { |source| Readline::HISTORY.push(source) }
    
    IRB::History.max_entries_in_overview = 5
    
    IRB::History.reset
  end
  
  it "returns nil so that IRB doesn't cache some arbitrary line number" do
    history.should == nil
  end
  
  it "prints a formatted list with, by default IRB::History.max_entries_in_overview, number of history entries" do
    history
    
    IRB::History.printed.should == %{
2: class A
3:   def bar
4:     p :ok
5:   end
6: end
}.sub(/\n/, '')
  end
  
  it "prints a formatted list of N most recent history entries" do
    history(7)
    
    IRB::History.printed.should == %{
0: puts :ok
1: foo(x)
2: class A
3:   def bar
4:     p :ok
5:   end
6: end
}.sub(/\n/, '')
  end
  
  it "prints a formatted list of all history entries if the request number of entries is more than there is" do
    history(777)

    IRB::History.printed.should == %{
0: puts :ok
1: foo(x)
2: class A
3:   def bar
4:     p :ok
5:   end
6: end
}.sub(/\n/, '')
  end
end