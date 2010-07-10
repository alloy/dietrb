require 'readline'
require 'irb/driver/tty'
require 'irb/ext/history'
require 'irb/ext/completion'

module IRB
  module Driver
    class Readline < TTY
      def initialize(input = $stdin, output = $stdout)
        super
        ::Readline.input  = @input
        ::Readline.output = @output
        ::Readline.completion_proc = IRB::Completion.new
      end
      
      # Assigns a context to the completion object and waits for input.
      def readline(context)
        ::Readline.completion_proc.context = context
        ::Readline.readline(context.prompt, true)
      end
    end
  end
end

IRB.driver = IRB::Driver::Readline.new