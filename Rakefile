task :default => :spec

desc "Run the specs"
task :spec do
  sh "macbacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
end

desc "Run specs with Kicker"
task :kick do
  sh "kicker -e 'rake spec' lib spec"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "dietrb"
    gemspec.summary = gemspec.description = "IRB on a diet, for MacRuby / Ruby 1.9"
    gemspec.email = "eloy.de.enige@gmail.com"
    gemspec.homepage = "http://github.com/alloy/dietrb"
    gemspec.authors = ["Eloy Duran"]
  end
rescue LoadError
end