require 'irb/context'
require 'irb/source'

require 'irb/ext/history'

if !ENV['SPECCING'] && defined?(RUBY_ENGINE) && RUBY_ENGINE == "macruby"
  require 'irb/ext/macruby'
end

module Kernel
  # Creates a new IRB::Context with the given +object+ and runs it.
  def irb(object, binding = nil)
    IRB::Context.new(object, binding).run
  end
  
  private :irb
end
