require 'irb/context'
require 'irb/source'

require 'irb/ext/history'

if !ENV['SPECCING'] && defined?(RUBY_ENGINE) && RUBY_ENGINE == "macruby"
  require 'irb/ext/macruby'
end
