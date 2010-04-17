require File.join(File.dirname(__FILE__), "spec_helper")

Platform = Module.new unless Object.const_defined?('Platform')
Net = Module.new unless Object.const_defined?('Net')

require 'flyrb'
Flyrb.equip(:gist)
include Flyrb::Gist
# don't go to the filesystem for the git credentials
def auth; {}; end

Clipboard = Flyrb::Clipboard unless Object.const_defined?('Clipboard')

describe "gist being called" do

  before(:all) do
    Net::HTTP = mock('HTTP') unless Net.const_defined?('HTTP')
    URI = mock('URI') unless Object.const_defined?('URI')
    Clipboard = mock('clipboard') unless Object.const_defined?('Clipboard')
  end

  before(:each) do
    @page = mock('page')
    @page.stub!(:[]).with('Location').and_return('foo.html')
    Net::HTTP.stub!(:post_form).and_return(@page)
    URI.stub!(:parse)
    Clipboard.stub!(:read)
    Clipboard.stub!(:write)
    Kernel.stub!(:system)
  end

  it "should be available in global namespace and not blow-up with default stub/mocking" do
    gist
  end

  it "should uri-parse the gist uri" do
    URI.should_receive(:parse).with("http://gist.github.com/gists")
    gist
  end

  it "should pass the uri-parsed result into the post" do
    URI.should_receive(:parse).and_return('a_uri_object')
    Net::HTTP.should_receive(:post_form).with('a_uri_object', anything()).and_return(@page)
    gist
  end

  it "should call system open on the gist return" do
    @page.should_receive(:[]).with('Location').and_return('returned_url')
    case Platform::IMPL
    when :macosx
      Kernel.should_receive(:system).with("open returned_url")
    when :mswin
      Kernel.should_receive(:system).with("start returned_url")
    end
    gist
  end

  it "should write resulting url into the clipboard" do
    @page.should_receive(:[]).and_return('returned_url')
    Clipboard.should_receive(:write).with('returned_url')
    gist
  end

  describe "with no parameter it uses the clipboard" do
    it "should read the clipboard" do
      Clipboard.should_receive(:read)
      gist
    end

    it "should put the clipboard results in the post to gist" do
      Clipboard.should_receive(:read).and_return('bar')
      Net::HTTP.should_receive(:post_form).with(anything(), {
        :"file_ext[gistfile1]" => "rb",
        :"file_name[gistfile1]" => "fly.rb",
        :"file_contents[gistfile1]" => 'bar'
      }).and_return(@page)
      gist
    end
  end

 describe "with a parameter instead" do
   #TODO: windows/linux safer now, since no clipboard functionality?
    it "should not even read the clipboard" do
      Clipboard.should_not_receive(:read)
      gist "baz"
    end

    it "should pass in the parameter instead" do
      Net::HTTP.should_receive(:post_form).with(anything(), {
        :"file_ext[gistfile1]" => "rb",
        :"file_name[gistfile1]" => "fly.rb",
        :"file_contents[gistfile1]" => 'baz',
      }).and_return(@page)
      
      gist "baz"
    end
  end
  
  describe "with a parameter and a filename" do
    it "should set the filename" do
      Net::HTTP.should_receive(:post_form).with(anything(), {
        :"file_ext[gistfile1]" => "rb",
        :"file_name[gistfile1]" => "lisp.el",
        :"file_contents[gistfile1]" => 'foo',
      }).and_return(@page)
      
      gist "foo", "lisp.el"
    end
  end
end
