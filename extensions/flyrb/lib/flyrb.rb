# This started as my (Giles Bowkett's) .irbrc file, turned into a recipe on IRB for the Pragmatic Programmers,
# and soon became a scrapbook of cool code snippets from all over the place. All the RDoc lives in the README.
# Check that file for usage information, authorship, copyright, and extensive details. You can also find a
# nice, HTMLified version of the README content at http://utilitybelt.rubyforge.org.

FLYRB_IRB_STARTUP_PROCS = {} unless Object.const_defined? :FLYRB_IRB_STARTUP_PROCS

%w{rubygems active_support flyrb/equipper}.each {|internal_library| require internal_library}

if Object.const_defined? :IRB

  # Called when the irb session is ready, after any external libraries have been loaded. This
  # allows the user to specify which gadgets in the utility belt to equip. (Kind of pushing the
  # metaphor, but hey, what the hell.)
  IRB.conf[:IRB_RC] = Proc.new do
    Flyrb.equip(:defaults) unless Flyrb.equipped?
    FLYRB_IRB_STARTUP_PROCS.each {|symbol, proc| proc.call}
  end
  
  # default: dark background
  Flyrb::Themes.background(:dark) if defined? Flyrb::Themes
end
