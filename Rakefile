task :default => :run

desc "Run the specs"
task :spec do
  sh "macbacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
end

desc "Run specs with Kicker"
task :kick do
  sh "kicker -e 'rake spec' lib spec"
end

desc "Run dietrb with ruby19"
task :run do
  sh "ruby19 -Ilib ./bin/dietrb -r irb/ext/completion"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "dietrb"
    gemspec.summary = gemspec.description = "IRB on a diet, for MacRuby / Ruby 1.9"
    gemspec.email = "eloy.de.enige@gmail.com"
    gemspec.homepage = "http://github.com/alloy/dietrb"
    gemspec.authors = ["Eloy Duran"]
    
    gemspec.required_ruby_version = ::Gem::Requirement.new("~> 1.9")
  end
rescue LoadError
end