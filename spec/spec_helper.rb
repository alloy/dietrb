require 'rubygems'
require 'bacon'

Bacon.summary_on_exit

ENV['SPECCING'] = 'true'

ROOT = File.expand_path('../../', __FILE__)
$:.unshift File.join(ROOT, 'lib')

require 'irb'
