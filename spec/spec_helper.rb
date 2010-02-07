require 'rubygems'
require 'bacon'

ENV['SPECCING'] = 'true'

ROOT = File.expand_path('../../', __FILE__)
$:.unshift File.join(ROOT, 'lib')

require 'irb'
