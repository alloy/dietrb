require 'irb/context'
require 'irb/source'

if !ENV['SPECCING'] && defined?(RUBY_ENGINE) && RUBY_ENGINE == "macruby"
  require 'irb/ext/macruby'
end

module Kernel
  # Creates a new IRB::Context with the given +object+ and runs it.
  def irb(object)
    IRB::Context.new(object).run
  end
  
  private :irb
end