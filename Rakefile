task :default => :spec

desc "Run the specs"
task :spec do
  sh "macbacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
end

desc "Run specs with Kicker"
task :kick do
  sh "kicker -e 'rake spec' lib spec"
end