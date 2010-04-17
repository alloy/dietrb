Gem::Specification.new do |s| 
  s.name = "flyrb"
  s.version = "1.0.0.b"
  s.author = "John Trupiano"
  s.email = "jtrupiano@gmail.com"
  s.homepage = "http://github.com/jtrupiano/flyrb"
  s.rubyforge_project = "flyrb"
  s.platform = Gem::Platform::RUBY
  s.summary = "A grab-bag of IRB power user madness (originaly Giles Bowkett's utility_belt)."
  s.files = ["bin", "bin/amazon", "bin/google", "bin/pastie", "History.txt", "html", "html/andreas00.css", "html/authorship.html", "html/bg.gif", "html/front.jpg", "html/index.html", "html/menubg.gif", "html/menubg2.gif", "html/test.jpg", "html/usage.html", "lib", "lib/flyrb", "lib/flyrb/amazon_upload_shortcut.rb", "lib/flyrb/clipboard.rb", "lib/flyrb/command_history.rb", "lib/flyrb/convertable_to_file.rb", "lib/flyrb/equipper.rb", "lib/flyrb/google.rb", "lib/flyrb/hash_math.rb", "lib/flyrb/interactive_editor.rb", "lib/flyrb/irb_options.rb", "lib/flyrb/irb_verbosity_control.rb", "lib/flyrb/is_an.rb", "lib/flyrb/gist.rb", "lib/flyrb/language_greps.rb", "lib/flyrb/not.rb", "lib/flyrb/pastie.rb", "lib/flyrb/pipe.rb", "lib/flyrb/rails_finder_shortcut.rb", "lib/flyrb/rails_verbosity_control.rb", "lib/flyrb/string_to_proc.rb", "lib/flyrb/symbol_to_proc.rb", "lib/flyrb/wirble.rb", "lib/flyrb/with.rb", "lib/flyrb.rb", "README", "spec", "spec/convertable_to_file_spec.rb", "spec/equipper_spec.rb", "spec/gist_spec.rb", "spec/hash_math_spec.rb", "spec/interactive_editor_spec.rb", "spec/language_greps_spec.rb", "spec/pastie_spec.rb", "spec/pipe_spec.rb", "spec/spec_helper.rb", "spec/string_to_proc_spec.rb", "spec/flyrb_spec.rb", "flyrb.gemspec"]
  %w{amazon google pastie}.each do |command_line_utility|
    s.executables << command_line_utility
  end
  s.require_path = "lib"
  s.test_file = "spec/flyrb_spec.rb"
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README"]
  s.add_dependency("activesupport")
  s.add_dependency("wirble", ">= 0.1.3")
  s.add_dependency("aws-s3", ">= 0.4.0")
  s.add_dependency("Platform", ">= 0.4.0")
end 
