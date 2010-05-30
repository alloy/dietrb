task :default => :run

desc "Run the specs"
task :spec do
  # sh "macbacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
  sh "bacon19 #{FileList['spec/**/*_spec.rb'].join(' ')}"
end

desc "Run specs with Kicker"
task :kick do
  sh "kicker -e 'rake spec' lib spec"
end

desc "Run dietrb with ruby19"
task :run do
  sh "ruby19 -Ilib ./bin/dietrb -r irb/ext/colorize -r pp"
end

desc "AOT compile for MacRuby"
task :macruby_compile do
  FileList["lib/**/*.rb"].each do |source|
    sh "macrubyc --arch i386 --arch x86_64 -C '#{source}' -o '#{source}o'"
  end
end

desc "Clean MacRuby binaries"
task :clean do
  FileList["lib/**/*.rbo"].each do |bin|
    rm bin
  end
end

begin
  require 'jeweler'
  require File.expand_path('../lib/irb/version', __FILE__)
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "dietrb"
    gemspec.version = IRB::VERSION::STRING
    gemspec.summary = gemspec.description = "IRB on a diet, for MacRuby / Ruby 1.9"
    gemspec.email = "eloy.de.enige@gmail.com"
    gemspec.homepage = "http://github.com/alloy/dietrb"
    gemspec.authors = ["Eloy Duran"]
    
    gemspec.required_ruby_version = ::Gem::Requirement.new("~> 1.9")
    gemspec.files.reject! { |file| file =~ /^extensions/ }
  end
rescue LoadError
end