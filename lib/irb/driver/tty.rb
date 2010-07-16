require 'irb/driver'

module IRB
  module Driver
    class TTY
      attr_reader :input, :output
      
      def initialize(input = $stdin, output = $stdout)
        @input  = input
        @output = output
      end
      
      def readline(context)
        @output.print(context.prompt)
        @input.gets
      end
      
      # TODO make it take the current context instead of storing it
      def consume(context)
        readline(context)
      rescue Interrupt
        context.clear_buffer
        ""
      end
      
      # Feeds input into a given context.
      #
      # Ensures that the standard output object is a OutputRedirector, or a
      # subclass thereof.
      def run(context)
        before, $stdout = $stdout, OutputRedirector.new unless $stdout.is_a?(OutputRedirector)
        while line = consume(context)
          break unless context.process_line(line)
        end
      ensure
        $stdout = before if before
      end
    end
  end
end

IRB::Driver.current = IRB::Driver::TTY.new

module Kernel
  # Creates a new IRB::Context with the given +object+ and runs it.
  def irb(object, binding = nil)
    IRB::Driver.current.run(IRB::Context.new(object, binding))
  end
  
  private :irb
end
