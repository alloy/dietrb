require 'irb/driver'

module IRB
  module Driver
    class TTY
      attr_reader :input, :output
      
      def initialize(input = $stdin, output = $stdout)
        @input  = input
        @output = output
        
        @thread_group = ThreadGroup.new
        @thread_group.add(Thread.current)
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
      
      def puts(*args)
        @output.puts(*args)
      end
      
      def print(*args)
        @output.print(*args)
        @output.flush
      end
      
      def run(context)
        ensure_output_redirector do
          while line = consume(context)
            continue = context.process_line(line)
            break unless continue
          end
        end
      end
      
      # Ensure that the standard output object is a OutputRedirector. If it's
      # already a OutputRedirector, do nothing.
      def ensure_output_redirector
        unless $stdout.is_a?(IRB::Driver::OutputRedirector)
          before, $stdout = $stdout, IRB::Driver::OutputRedirector.new
        end
        yield
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