framework 'AppKit'

module IRB
  class Context
    alias_method :_run, :run
    
    def run
      if NSApplication.sharedApplication.running?
        _run
      else
        Thread.new do
          _run
          NSApplication.sharedApplication.terminate(self)
        end
        NSApplication.sharedApplication.run
      end
    end
  end
end