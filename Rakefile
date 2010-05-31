def ruby_bin
  require 'rbconfig'
  File.join(Config::CONFIG['prefix'], 'bin', Config::CONFIG['ruby_install_name'])
end

task :default => :run

desc "Run the specs (run it with a rake installed on the Ruby version you want to run the specs on)"
task :spec do
  sh "#{ruby_bin} -r #{FileList['./spec/**/*_spec.rb'].join(' -r ')} -e ''"
end

desc "Run dietrb"
task :run do
  sh "#{ruby_bin} -I lib ./bin/dietrb -r irb/ext/colorize -r pp"
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
    gemspec.files.reject! { |file| file =~ /^(extensions|\.gitignore)/ }
  end
rescue LoadError
end
