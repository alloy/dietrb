require 'irb/context'
require 'irb/source'

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "macruby"
  require 'irb/ext/macruby'
end