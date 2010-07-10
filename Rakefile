def ruby_bin
  require 'rbconfig'
  File.join(Config::CONFIG['prefix'], 'bin', Config::CONFIG['ruby_install_name'])
end

task :default => :run

desc "Run the specs (run it with a rake installed on the Ruby version you want to run the specs on)"
task :spec do
  sh "mspec -t #{ruby_bin} spec"
end

desc "Run dietrb"
task :run do
  sh "#{ruby_bin} -I lib ./bin/dietrb -d -r irb/ext/colorize -r pp"
end

namespace :macruby do
  desc "AOT compile for MacRuby"
  task :compile do
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
  
  desc "Merge source into the MacRuby repo"
  task :merge do
    if (repo = ENV['macruby_repo']) && File.exist?(repo)
      bin  = File.join(repo, 'bin/irb')
      lib  = File.join(repo, 'lib')
      spec = File.join(repo, 'spec/dietrb')
      
      rm_f  bin
      rm_f  File.join(lib, 'irb.rb')
      rm_rf File.join(lib, 'irb')
      rm_rf spec
      
      cp   'bin/dietrb', bin
      cp   'lib/irb.rb', lib
      cp_r 'lib/irb',    lib
      cp_r 'spec',       spec
    else
      puts "[!] Set the `macruby_repo' env variable to point to the MacRuby repo checkout"
      exit 1
    end
  end
end

# begin
#   require 'rubygems'
#   require 'jeweler'
#   require File.expand_path('../lib/irb/version', __FILE__)
#   Jeweler::Tasks.new do |gemspec|
#     gemspec.name = "dietrb"
#     gemspec.version = IRB::VERSION::STRING
#     gemspec.summary = gemspec.description = "IRB on a diet, for MacRuby / Ruby 1.9"
#     gemspec.email = "eloy.de.enige@gmail.com"
#     gemspec.homepage = "http://github.com/alloy/dietrb"
#     gemspec.authors = ["Eloy Duran"]
#     
#     gemspec.required_ruby_version = ::Gem::Requirement.new("~> 1.9")
#     gemspec.files.reject! { |file| file =~ /^(extensions|\.gitignore)/ }
#   end
# rescue LoadError
# end
