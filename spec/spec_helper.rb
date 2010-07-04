unless defined?(MSpec)
  require 'rubygems'
  require 'mspec'
end

ENV['SPECCING'] = 'true'

root = File.expand_path('../../', __FILE__)
if File.basename(root) == 'spec'
  # running from the MacRuby repo
  ROOT = File.expand_path('../../../', __FILE__)
else
  ROOT = root
end
$:.unshift File.join(ROOT, 'lib')

require 'irb'

class CaptureIO
  def printed
    @printed ||= ''
  end
  
  def print(string)
    printed << string
  end
  
  def puts(string)
    print "#{string}\n"
  end
  
  def stub_input(*input)
    @input = input
  end
  
  def readline(prompt)
    print prompt
    @input.shift
  end
end